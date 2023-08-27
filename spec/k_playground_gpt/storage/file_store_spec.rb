# frozen_string_literal: true

RSpec.describe KPlaygroundGpt::Storage::FileStore do
  let(:filename) { 'tmp/test.txt' }
  let(:data) { 'sample_data' }
  let(:file_store) { described_class.new(filename) }

  before do
    FileUtils.rm_f(filename)
  end

  after do
    FileUtils.rm_f(filename)
  end

  describe '#read' do
    subject { file_store.read }

    context 'when file does not exist' do
      it { is_expected.to be_nil }
    end

    context 'when file exists' do
      before { File.write(filename, data) }

      it { is_expected.to eq(data) }
    end
  end

  describe '#write' do
    subject { file_store.write(data) }

    it 'writes to the file' do
      expect { subject }.to change { File.exist?(filename) }.from(false).to(true)
    end
  end
end
