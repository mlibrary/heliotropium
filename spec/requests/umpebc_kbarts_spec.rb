# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "UmpebcKbarts", type: :request do
  let(:target) { create(:umpebc_kbart) }

  describe '#index' do
    subject(:get_index) { get "/umpebc_kbarts" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/umpebc_kbarts?name_like=#{target.name}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/umpebc_kbarts/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/umpebc_kbarts/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/umpebc_kbarts/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/umpebc_kbarts", params: { umpebc_kbart: umpebc_kbart_params } }

    let(:umpebc_kbart_params) { { name: 'name' } }

    before { post_create }

    it { expect(response).to redirect_to(umpebc_kbart_path(UmpebcKbart.find_by(umpebc_kbart_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid umpebc_kbart params' do
      let(:umpebc_kbart_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/umpebc_kbarts/#{target.id}", params: { umpebc_kbart: umpebc_kbart_params } }

    let(:umpebc_kbart_params) { { name: 'new_name' } }

    before { put_update }

    it { expect(response).to redirect_to(umpebc_kbart_path(UmpebcKbart.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid umpebc_kbart params' do
      let(:umpebc_kbart_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/umpebc_kbarts/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(umpebc_kbarts_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { UmpebcKbart.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
