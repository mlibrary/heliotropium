# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "UmpebcMarcs", type: :request do
  let(:target) { create(:umpebc_marc) }

  describe '#index' do
    subject(:get_index) { get "/umpebc_marcs" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/umpebc_marcs?doi_like=#{target.doi}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/umpebc_marcs/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/umpebc_marcs/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/umpebc_marcs/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/umpebc_marcs", params: { umpebc_marc: umpebc_marc_params } }

    let(:umpebc_marc_params) { { doi: 'doi', mrc: 'mrc' } }

    before { post_create }

    it { expect(response).to redirect_to(umpebc_marc_path(UmpebcMarc.find_by(umpebc_marc_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid umpebc_marc params' do
      let(:umpebc_marc_params) { { doi: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/umpebc_marcs/#{target.id}", params: { umpebc_marc: umpebc_marc_params } }

    let(:umpebc_marc_params) { { doi: 'new_doi' } }

    before { put_update }

    it { expect(response).to redirect_to(umpebc_marc_path(UmpebcMarc.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid umpebc_marc params' do
      let(:umpebc_marc_params) { { doi: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/umpebc_marcs/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(umpebc_marcs_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { UmpebcMarc.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
