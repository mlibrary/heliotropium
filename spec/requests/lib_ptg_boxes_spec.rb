# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "LibPtgBoxes", type: :request do
  describe "GET /lib_ptg_boxes" do
    it "works! (now write some real specs)" do
      get lib_ptg_boxes_path
      expect(response).to have_http_status(200)
    end
  end
end
