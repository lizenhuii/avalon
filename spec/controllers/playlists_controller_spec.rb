require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe PlaylistsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Playlist. As you add validations to Playlist, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { title: Faker::Lorem.word, visibility: Playlist::PUBLIC, user: user }
  end

  let(:invalid_attributes) do
    { visibility: 'unknown' }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PlaylistsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:user) { login_as :user }

  describe 'GET #index' do
    it 'assigns accessible playlists as @playlists' do
      # TODO: test non-accessible playlists not appearing
      playlist = Playlist.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:playlists)).to eq([playlist])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested playlist as @playlist' do
      playlist = Playlist.create! valid_attributes
      get :show, { id: playlist.to_param }, valid_session
      expect(assigns(:playlist)).to eq(playlist)
    end
    # TODO: write tests for public/private playists
  end

  describe 'GET #new' do
    it 'assigns a new playlist as @playlist' do
      get :new, {}, valid_session
      expect(assigns(:playlist)).to be_a_new(Playlist)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested playlist as @playlist' do
      playlist = Playlist.create! valid_attributes
      get :edit, { id: playlist.to_param }, valid_session
      expect(assigns(:playlist)).to eq(playlist)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Playlist' do
        expect do
          post :create, { playlist: valid_attributes }, valid_session
        end.to change(Playlist, :count).by(1)
      end

      it 'assigns a newly created playlist as @playlist' do
        post :create, { playlist: valid_attributes }, valid_session
        expect(assigns(:playlist)).to be_a(Playlist)
        expect(assigns(:playlist)).to be_persisted
      end

      it 'redirects to the created playlist' do
        post :create, { playlist: valid_attributes }, valid_session
        expect(response).to redirect_to(Playlist.last)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved playlist as @playlist' do
        post :create, { playlist: invalid_attributes }, valid_session
        expect(assigns(:playlist)).to be_a_new(Playlist)
      end

      it "re-renders the 'new' template" do
        post :create, { playlist: invalid_attributes }, valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { title: Faker::Lorem.word, visibility: Playlist::PUBLIC, comment: Faker::Lorem.sentence }
      end

      it 'updates the requested playlist' do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: new_attributes }, valid_session
        playlist.reload
        expect(playlist.title).to eq new_attributes[:title]
        expect(playlist.visibility).to eq new_attributes[:visibility]
        expect(playlist.comment).to eq new_attributes[:comment]
      end

      it 'assigns the requested playlist as @playlist' do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: valid_attributes }, valid_session
        expect(assigns(:playlist)).to eq(playlist)
      end

      it 'redirects to edit playlist' do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: valid_attributes }, valid_session
        expect(response).to redirect_to(edit_playlist_path(playlist))
      end
    end

    context 'with invalid params' do
      it 'assigns the playlist as @playlist' do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: invalid_attributes }, valid_session
        expect(assigns(:playlist)).to eq(playlist)
      end

      it "re-renders the 'edit' template" do
        playlist = Playlist.create! valid_attributes
        put :update, { id: playlist.to_param, playlist: invalid_attributes }, valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'PUT #update_multiple' do
    context 'delete' do
      it 'redirects to edit playlist' do
        playlist = Playlist.create! valid_attributes
        put :update_multiple, { id: playlist.to_param, annotation_ids: [] }, valid_session
        expect(response).to redirect_to(edit_playlist_path(playlist))
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested playlist' do
      playlist = Playlist.create! valid_attributes
      expect do
        delete :destroy, { id: playlist.to_param }, valid_session
      end.to change(Playlist, :count).by(-1)
    end

    it 'redirects to the playlists list' do
      playlist = Playlist.create! valid_attributes
      delete :destroy, { id: playlist.to_param }, valid_session
      expect(response).to redirect_to(playlists_url)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested playlist as @playlist' do
      playlist = Playlist.create! valid_attributes
      get :edit, { id: playlist.to_param }, valid_session
      expect(assigns(:playlist)).to eq(playlist)
    end
  end

end
