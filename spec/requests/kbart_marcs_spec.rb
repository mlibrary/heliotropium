# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "KbartMarcs", type: :request do
  let(:target) { create(:kbart_marc) }

  describe '#index' do
    subject(:get_index) { get "/kbart_marcs" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/kbart_marcs?doi_like=#{target.doi}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/kbart_marcs/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/kbart_marcs/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/kbart_marcs/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/kbart_marcs", params: { kbart_marc: kbart_marc_params } }

    let(:kbart_marc_params) { { folder: 'folder', file: 'file', doi: 'doi' } }

    before { post_create }

    it { expect(response).to redirect_to(kbart_marc_path(KbartMarc.find_by(kbart_marc_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid kbart_marc params' do
      let(:kbart_marc_params) { { doi: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/kbart_marcs/#{target.id}", params: { kbart_marc: kbart_marc_params } }

    let(:kbart_marc_params) { { doi: 'new_doi' } }

    before { put_update }

    it { expect(response).to redirect_to(kbart_marc_path(KbartMarc.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid kbart_marc params' do
      let(:kbart_marc_params) { { doi: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/kbart_marcs/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(kbart_marcs_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { KbartMarc.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
