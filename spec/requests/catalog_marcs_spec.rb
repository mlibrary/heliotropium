# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "CatalogMarcs", type: :request do
  let(:target) { create(:catalog_marc) }

  describe '#index' do
    subject(:get_index) { get "/catalog_marcs" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/catalog_marcs?folder_like=#{target.folder}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/catalog_marcs/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/catalog_marcs/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/catalog_marcs/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/catalog_marcs", params: { catalog_marc: catalog_marc_params } }

    let(:catalog_marc_params) { { folder: 'folder', file: 'file' } }

    before { post_create }

    it { expect(response).to redirect_to(catalog_marc_path(CatalogMarc.find_by(catalog_marc_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid catalog_marc params' do
      let(:catalog_marc_params) { { folder: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/catalog_marcs/#{target.id}", params: { catalog_marc: catalog_marc_params } }

    let(:catalog_marc_params) { { folder: 'new_folder' } }

    before { put_update }

    it { expect(response).to redirect_to(catalog_marc_path(CatalogMarc.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid catalog_marc params' do
      let(:catalog_marc_params) { { folder: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/catalog_marcs/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(catalog_marcs_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { CatalogMarc.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
