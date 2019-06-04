# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "UuidIidentifiers", type: :request do
  let(:target) { create(:uuid_identifier) }

  describe '#index' do
    subject(:get_index) { get "/uuid_identifiers" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#show' do
    subject(:get_show) { get "/uuid_identifiers/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/uuid_identifiers/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/uuid_identifiers/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/uuid_identifiers", params: { uuid_identifier: uuid_identifier_params } }

    let(:uuid_identifier_params) { { uuid_id: uuid.id, identifier_id: identifier.id } }
    let(:uuid) { create(:uuid) }
    let(:identifier) { create(:identifier) }

    before { post_create }

    it { expect(response).to redirect_to(uuid_identifier_path(UuidIdentifier.find_by(uuid_identifier_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid uuid identifier params' do
      let(:uuid_identifier_params) { { uuid_id: 0, identifier_id: 0 } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/uuid_identifiers/#{target.id}", params: { uuid_identifier: uuid_identifier_params } }

    let(:uuid_identifier_params) { { uuid_id: uuid.id, identifier_id: identifier.id } }
    let(:uuid) { create(:uuid) }
    let(:identifier) { create(:identifier) }

    before { put_update }

    it { expect(response).to redirect_to(uuid_identifier_path(UuidIdentifier.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid uuid identifier params' do
      let(:uuid_identifier_params) { { uuid_id: 0, identifier_id: 0 } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/uuid_identifiers/#{target.id}" }

    context 'without alias' do
      before { delete_destroy }

      it { expect(response).to redirect_to(uuid_identifiers_path) }
      it { expect(response).to have_http_status(:found) }
      it { expect { UuidIdentifier.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
