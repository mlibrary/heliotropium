require 'rails_helper'

RSpec.describe "UmpebcKbarts", type: :request do
  describe "GET /umpebc_kbarts" do
    it "works! (now write some real specs)" do
      get umpebc_kbarts_path
      expect(response).to have_http_status(200)
    end
  end
end
