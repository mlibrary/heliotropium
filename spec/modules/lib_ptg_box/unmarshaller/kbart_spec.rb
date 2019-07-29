# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibPtgBox::Unmarshaller::Kbart do
  subject(:kbart) { described_class.new(line) }

  let(:line) { instance_double(String, 'line', encoding: 'encoding', valid_encoding?: true) }

  before do
    allow(line).to receive(:force_encoding).with('UTF-8').and_return(line)
    allow(line).to receive(:encode).with('UTF-8').and_return(line)
  end

  describe '#doi' do
    subject { kbart.doi }

    it { is_expected.to eq("10.3998/mpub.00000000") }

    context 'with doi' do
      let(:line) { +'"publication_title","print_identifier","online_identifier","date_first_issue_online","num_first_vol_online","num_first_issue_online","date_last_issue_online","num_last_vol_online","num_last_issue_online","title_url","first_author","title_id","embargo_info","coverage_depth","coverage_notes","publisher_name"' }

      it { is_expected.to eq("title_id") }
    end
  end
end
