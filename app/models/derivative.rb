# Copyright 2011-2015, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
# 
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed 
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the 
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

require 'avalon/matterhorn_rtmp_url'

class Derivative < ActiveFedora::Base
  include ActiveFedora::Associations
  include VersionableModel

  class_attribute :url_handler

  belongs_to :masterfile, :class_name=>'MasterFile', :property=>:is_derivation_of

  has_model_version 'R3'

  # These fields do not fit neatly into the Dublin Core so until a long
  # term solution is found they are stored in a simple datastream in a
  # relatively flat structure.
  #
  # The only meaningful value at the moment is the url, which points to
  # the stream location. The other two are just stored until a migration
  # strategy is required.
  has_metadata name: "descMetadata", :type => ActiveFedora::SimpleDatastream do |d|
    d.field :location_url, :string
    d.field :hls_url, :string
    d.field :duration, :string
    d.field :track_id, :string
    d.field :hls_track_id, :string
  end

  has_metadata name: 'derivativeFile', type: UrlDatastream

  has_attributes :location_url, :hls_url, :duration, :track_id, :hls_track_id, datastream: :descMetadata, multiple: false

  has_metadata name: 'encoding', type: EncodingProfileDocument

  def self.url_handler
    url_handler_class = Avalon::Configuration.lookup('streaming.server').to_s.classify
    @url_handler ||= UrlHandler.const_get(url_handler_class.to_sym)
  end

  # Getting the track ID from the fragment is not great but it does reduce the number
  # of calls to Matterhorn 
  def self.create_from_master_file(masterfile, quality, entries, opts = {})
    # Looks for an existing derivative of the same quality
    # and adds the track URL to it
    masterfile = MasterFile.find(masterfile.pid)
    existing = masterfile.derivatives.to_a.select {|d| d.encoding.quality.first == quality }

    # If same quality derivative doesn't exist, create one
    derivative = Derivative.new 
    
    hls_markup = entries['hls']
    markup = entries['rtmp']
    derivative.duration = markup.duration.first
    derivative.encoding.mime_type = markup.mimetype.first
    derivative.encoding.quality = quality 

    derivative.encoding.audio.audio_bitrate = markup.audio.a_bitrate.first
    derivative.encoding.audio.audio_codec = markup.audio.a_codec.first
 
    unless markup.video.empty?
      derivative.encoding.video.video_bitrate = markup.video.v_bitrate.first
      derivative.encoding.video.video_codec = markup.video.v_codec.first
      derivative.encoding.video.resolution = markup.video.resolution.first
    end

    derivative.track_id = markup.track_id.first
    derivative.location_url = markup.url.first
    derivative.absolute_location = File.join(opts[:stream_base], Avalon::MatterhornRtmpUrl.parse(derivative.location_url).to_path) if opts[:stream_base]

    if hls_markup.present?
      derivative.hls_track_id = hls_markup.track_id.first
      derivative.hls_url = hls_markup.url.first
    end

    derivative.masterfile = masterfile
    if derivative.save
      #Remove old derivatives only if save succeeds
      existing.map(&:delete)
    end
    
    derivative
  end

  def absolute_location
    derivativeFile.location
  end

  def absolute_location=(value)
    derivativeFile.location = value
  end

  def media_package_id
    Avalon::MatterhornRtmpUrl.parse(location_url).media_id
  end

  def tokenized_url(token, mobile=false)
    #uri = URI.parse(url.first)
    uri = streaming_url(mobile)
    "#{uri.to_s}?token=#{masterfile.mediapackage_id}-#{token}".html_safe
  end

  def streaming_url(is_mobile=false)
    # We need to tweak the RTMP stream to reflect the right format for AMS.
    # That means extracting the extension from the end and placing it just
    # after the application in the URL

    protocol = is_mobile ? 'http' : 'rtmp'

    rtmp_url = Avalon::MatterhornRtmpUrl.parse location_url
    if rtmp_url.extension.nil? or rtmp_url.prefix.nil?
      rtmp_url.prefix = rtmp_url.extension = [rtmp_url.extension,rtmp_url.prefix].find { |thing| not thing.nil? }
    end

    template = ERB.new(self.class.url_handler.patterns[protocol][format])
    result = File.join(Avalon::Configuration.lookup("streaming.#{protocol}_base"),template.result(rtmp_url.binding))
  end

  def format
    case
      when (not encoding.video.empty?)
        "video"
      when (not encoding.audio.empty?)
        "audio"
      else
        "other"
      end
  end

  def delete
    #catch exceptions and log them but don't stop the deletion of the derivative object!
    #TODO move this into a before_destroy callback
    begin
      job_urls = []
      media_package = Rubyhorn.client.get_media_package_from_id(media_package_id)
      job_urls << Rubyhorn.client.delete_track(media_package, track_id) 
      job_urls << Rubyhorn.client.delete_hls_track(media_package, hls_track_id) if hls_track_id.present?

      # Logs retraction jobs for sysadmin 
      File.open(Avalon::Configuration.lookup('matterhorn.cleanup_log'), "a+") { |f| f << job_urls.join("\n") + "\n" }
    rescue Exception => e
      logger.warn "Error deleting derivative: #{e.message}"
    end

    super
  end
end 
