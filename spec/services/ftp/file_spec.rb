# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ftp::File do
  subject(:file) { described_class.new(service, pathname, facts) }

  let(:service) { instance_double(Ftp::Service, 'service', host: 'host', user: 'user', password: 'password') }
  let(:pathname) { File.join(dirname, filename) }
  let(:dirname) { 'dir' }
  let(:extension) { 'ext' }
  let(:filename) { 'file' + '.' + extension }
  let(:facts) { { 'type' => 'file', 'modify' => Time.now.to_s } }

  describe '#null_file' do
    subject(:null_file) { described_class.null_file }

    it { is_expected.to be_an_instance_of(Ftp::NullFile) }
    it { expect(null_file.name).to be_empty }
    it { expect(null_file.content).to be_empty }
  end

  describe '#name' do
    subject { file.name }

    it { is_expected.to eq(filename) }
  end

  describe '#extension' do
    subject { file.extension }

    it { is_expected.to eq('.' + extension) }
  end

  describe '#updated' do
    subject { file.updated }

    it { is_expected.to eq(Date.today) }
  end

  describe '#content' do
    subject { file.content }

    let(:ftp) { instance_double(Net::FTP, 'ftp') }
    let(:content) { '' }

    before do
      allow(Net::FTP).to receive(:open).with(service.host, username: service.user, password: service.password, ssl: true).and_yield(ftp)
      allow(ftp).to receive(:chdir).with(dirname)
      allow(ftp).to receive(:getbinaryfile).with(filename, nil).and_return(content)
    end

    it { is_expected.to be_empty }

    context 'with chdir error' do
      before { allow(ftp).to receive(:chdir).with(dirname).and_raise(RuntimeError) }

      it { is_expected.to be_empty }
    end

    context 'with get error' do
      before { allow(ftp).to receive(:getbinaryfile).with(filename, nil).and_raise(RuntimeError) }

      it { is_expected.to be_empty }
    end

    context 'with content' do
      let(:content) { 'content' }

      it { is_expected.to eq(content) }
    end
  end
end
