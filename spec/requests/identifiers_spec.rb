# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Identifiers", type: :request do
  let(:target) { create(:identifier, uuid: uuid) }
  let(:uuid) { create(:uuid) }

  before { allow(Uuid).to receive(:uuid_generator_packed).and_return(Support.random_uuid_packed) }

  describe '#index' do
    subject(:get_index) { get "/identifiers" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/identifiers?name_like=#{target.name}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/identifiers/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/identifiers/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/identifiers/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/identifiers", params: { identifier: identifier_params } }

    let(:identifier_params) { { name: 'name' } }

    before { post_create }

    it { expect(response).to redirect_to(identifier_path(Identifier.find_by(identifier_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'with alias' do
      let(:identifier_params) { { name: 'name', uuid: target.id } }

      it { expect(response).to redirect_to(identifier_path(Identifier.find_by(name: identifier_params[:name]))) }
      it { expect(response).to have_http_status(:found) }
    end

    context 'when invalid identifier params' do
      let(:identifier_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/identifiers/#{target.id}", params: { identifier: identifier_params } }

    let(:identifier_params) { { name: 'new_name' } }

    before { put_update }

    it { expect(response).to redirect_to(identifier_path(Identifier.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'with uuid' do
      let(:identifier_params) { { name: 'name', uuid: other.id } }
      let(:other) { create(:identifier, uuid: other_uuid) }
      let(:other_uuid) { create(:uuid) }

      it { expect(response).to redirect_to(identifier_path(Identifier.find(target.id))) }
      it { expect(response).to have_http_status(:found) }
    end

    context 'when invalid identifier params' do
      let(:identifier_params) { { name: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/identifiers/#{target.id}" }

    context 'without alias' do
      before { delete_destroy }

      it { expect(response).to redirect_to(identifiers_path) }
      it { expect(response).to have_http_status(:found) }
      it { expect { Identifier.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
      it { expect { Uuid.find(target.uuid.id) }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    it 'with alias' do # rubocop:disable RSpec/ExampleLength
      twin = create(:identifier, uuid: target.uuid)
      expect(target.uuid).to eq(twin.uuid)
      expect { delete_destroy }.not_to raise_error
      expect(response).to redirect_to(identifiers_path)
      expect(response).to have_http_status(:found)
      expect { Identifier.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Uuid.find(target.uuid.id) }.not_to raise_error
      expect { Identifier.find(twin.id) }.not_to raise_error
      expect { Uuid.find(twin.uuid.id) }.not_to raise_error
    end
  end
end
