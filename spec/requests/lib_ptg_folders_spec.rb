# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "LibPtgFolders", type: :request do
  let(:target) { create(:lib_ptg_folder) }

  describe '#index' do
    subject(:get_index) { get "/lib_ptg_folders" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/lib_ptg_folders?name_like=#{target.name}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/lib_ptg_folders/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/lib_ptg_folders/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/lib_ptg_folders/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/lib_ptg_folders", params: { lib_ptg_folder: lib_ptg_folder_params } }

    let(:lib_ptg_folder_params) { { name: 'name' } }

    before { post_create }

    it { expect(response).to redirect_to(lib_ptg_folder_path(LibPtgFolder.find_by(lib_ptg_folder_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid lib_ptg_folder params' do
      let(:lib_ptg_folder_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/lib_ptg_folders/#{target.id}", params: { lib_ptg_folder: lib_ptg_folder_params } }

    let(:lib_ptg_folder_params) { { name: 'new_name' } }

    before { put_update }

    it { expect(response).to redirect_to(lib_ptg_folder_path(LibPtgFolder.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid lib_ptg_folder params' do
      let(:lib_ptg_folder_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/lib_ptg_folders/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(lib_ptg_folders_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { LibPtgFolder.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
