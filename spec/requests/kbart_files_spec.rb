# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "KbartFiles", type: :request do
  let(:target) { create(:kbart_file) }

  describe '#index' do
    subject(:get_index) { get "/kbart_files" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/kbart_files?name_like=#{target.name}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/kbart_files/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/kbart_files/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/kbart_files/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/kbart_files", params: { kbart_file: kbart_file_params } }

    let(:kbart_file_params) { { folder: 'folder', name: 'name' } }

    before { post_create }

    it { expect(response).to redirect_to(kbart_file_path(KbartFile.find_by(kbart_file_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid kbart_file params' do
      let(:kbart_file_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/kbart_files/#{target.id}", params: { kbart_file: kbart_file_params } }

    let(:kbart_file_params) { { name: 'new_name' } }

    before { put_update }

    it { expect(response).to redirect_to(kbart_file_path(KbartFile.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid kbart_file params' do
      let(:kbart_file_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/kbart_files/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(kbart_files_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { KbartFile.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
