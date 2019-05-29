# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Uuids", type: :request do
  let(:target) { create(:uuid) }

  describe '#index' do
    subject(:get_index) { get "/uuids" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/uuids?unpacked_like=#{target.unpacked}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/uuids/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/uuids/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/uuids/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/uuids", params: { uuid: uuid_params } }

    let(:uuid_params) { { packed: 'packed', unpacked: 'unpacked' } }

    before { post_create }

    it { expect(response).to redirect_to(uuid_path(Uuid.find_by(uuid_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid uuid params' do
      let(:uuid_params) { { packed: '', unpacked: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/uuids/#{target.id}", params: { uuid: uuid_params } }

    let(:uuid_params) { { packed: 'new_packed', unpacked: 'new_unpacked' } }

    before { put_update }

    it { expect(response).to redirect_to(uuid_path(Uuid.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid uuid params' do
      let(:uuid_params) { { packed: '', unpacked: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/uuids/#{target.id}" }

    context 'without alias' do
      before { delete_destroy }

      it { expect(response).to redirect_to(uuids_path) }
      it { expect(response).to have_http_status(:found) }
      it { expect { Uuid.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
