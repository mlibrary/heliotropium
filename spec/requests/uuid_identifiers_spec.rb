# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "UuidIdentifiers", type: :request do
  describe "GET /uuid_identifiers" do
    it "works! (now write some real specs)" do
      get uuid_identifiers_path
      expect(response).to have_http_status(200)
    end
  end
end
