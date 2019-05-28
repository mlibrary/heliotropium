# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Uuids", type: :request do
  describe "GET /uuids" do
    it "works! (now write some real specs)" do
      get uuids_path
      expect(response).to have_http_status(200)
    end
  end
end
