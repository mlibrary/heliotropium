# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "UmpebcFiles", type: :request do
  let(:target) { create(:umpebc_file) }

  describe '#index' do
    subject(:get_index) { get "/umpebc_files" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/umpebc_files?name_like=#{target.name}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/umpebc_files/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/umpebc_files/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/umpebc_files/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/umpebc_files", params: { umpebc_file: umpebc_file_params } }

    let(:umpebc_file_params) { { name: 'name' } }

    before { post_create }

    it { expect(response).to redirect_to(umpebc_file_path(UmpebcFile.find_by(umpebc_file_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid umpebc_file params' do
      let(:umpebc_file_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/umpebc_files/#{target.id}", params: { umpebc_file: umpebc_file_params } }

    let(:umpebc_file_params) { { name: 'new_name' } }

    before { put_update }

    it { expect(response).to redirect_to(umpebc_file_path(UmpebcFile.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid umpebc_file params' do
      let(:umpebc_file_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/umpebc_files/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(umpebc_files_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { UmpebcFile.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
