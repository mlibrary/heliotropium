# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "MarcFiles", type: :request do
  let(:target) { create(:marc_file) }

  describe '#index' do
    subject(:get_index) { get "/marc_files" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/marc_files?name_like=#{target.name}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/marc_files/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/marc_files/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/marc_files/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/marc_files", params: { marc_file: marc_file_params } }

    let(:marc_file_params) { { folder: 'folder', name: 'name' } }

    before { post_create }

    it { expect(response).to redirect_to(marc_file_path(MarcFile.find_by(marc_file_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid marc_file params' do
      let(:marc_file_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/marc_files/#{target.id}", params: { marc_file: marc_file_params } }

    let(:marc_file_params) { { name: 'new_name' } }

    before { put_update }

    it { expect(response).to redirect_to(marc_file_path(MarcFile.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid marc_file params' do
      let(:marc_file_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/marc_files/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(marc_files_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { MarcFile.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
