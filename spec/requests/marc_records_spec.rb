# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "MarcRecords", type: :request do
  let(:target) { create(:marc_record) }

  describe '#index' do
    subject(:get_index) { get "/marc_records" }

    before { get_index }

    it { expect(response).to have_http_status(:ok) }

    context 'when filtering' do
      subject(:get_index) { get "/marc_records?folder_like=#{target.folder}" }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#show' do
    subject(:get_show) { get "/marc_records/#{target.id}" }

    before { get_show }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#new' do
    subject(:get_new) { get "/marc_records/new" }

    before { get_new }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#edit' do
    subject(:get_edit) { get "/marc_records/#{target.id}/edit" }

    before { get_edit }

    it { expect(response).to have_http_status(:ok) }
  end

  describe '#create' do
    subject(:post_create) { post "/marc_records", params: { marc_record: marc_record_params } }

    let(:marc_record_params) { { folder: 'folder', file: 'file' } }

    before { post_create }

    it { expect(response).to redirect_to(marc_record_path(MarcRecord.find_by(marc_record_params))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid marc_record params' do
      let(:marc_record_params) { { folder: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#update' do
    subject(:put_update) { put "/marc_records/#{target.id}", params: { marc_record: marc_record_params } }

    let(:marc_record_params) { { folder: 'new_folder' } }

    before { put_update }

    it { expect(response).to redirect_to(marc_record_path(MarcRecord.find(target.id))) }
    it { expect(response).to have_http_status(:found) }

    context 'when invalid marc_record params' do
      let(:marc_record_params) { { folder: '' } }

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete "/marc_records/#{target.id}" }

    before { delete_destroy }

    it { expect(response).to redirect_to(marc_records_path) }
    it { expect(response).to have_http_status(:found) }
    it { expect { MarcRecord.find(target.id) }.to raise_error(ActiveRecord::RecordNotFound) }
  end
end
