require 'rails_helper'

RSpec.describe "LibPtgFolders", type: :request do
  describe "GET /lib_ptg_folders" do
    it "works! (now write some real specs)" do
      get lib_ptg_folders_path
      expect(response).to have_http_status(200)
    end
  end
end
