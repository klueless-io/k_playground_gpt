# frozen_string_literal: true

RSpec.describe KPlaygroundGpt::Storage::BaseStore do
  subject(:store) { described_class.new }

  describe '#read' do
    it { expect { store.read }.to raise_error(NotImplementedError, "#{described_class} has not implemented method 'read'") }
  end

  describe '#write' do
    it { expect { store.write('sample_data') }.to raise_error(NotImplementedError, "#{described_class} has not implemented method 'write'") }
  end
end
