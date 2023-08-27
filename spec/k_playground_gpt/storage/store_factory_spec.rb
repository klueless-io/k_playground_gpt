# frozen_string_literal: true

RSpec.describe KPlaygroundGpt::Storage::StoreFactory do
  describe '.build' do
    subject(:store) { described_class.build(store_identifier) }

    context 'with a symbol' do
      let(:store_identifier) { :save_last_file }

      it 'returns a FileStore instance for :save_last_file' do
        expect(store).to be_a(KPlaygroundGpt::Storage::FileStore)
        expect(store.filename).to eq('.last-chat.json')
      end

      it 'raises an error for unknown symbols' do
        expect { described_class.build(:unknown) }.to raise_error('Unsupported store identifier: unknown')
      end
    end

    context 'with a class' do
      let(:mock_store_class) do
        Class.new(KPlaygroundGpt::Storage::BaseStore)
      end

      it 'returns an instance of the given class' do
        store = described_class.build(mock_store_class)
        expect(store).to be_a(mock_store_class)
      end
    end

    context 'with an instance' do
      let(:store_instance) { KPlaygroundGpt::Storage::FileStore.new('some_path.json') }

      it 'returns the provided instance' do
        store = described_class.build(store_instance)
        expect(store).to be(store_instance)
      end
    end

    context 'with an unsupported identifier' do
      it 'raises an error' do
        expect { described_class.build('unsupported_string') }.to raise_error('Unsupported store identifier: unsupported_string')
      end
    end

    context 'with nil value' do
      it 'return nil' do
        expect(described_class.build(nil)).to be_nil
      end
    end
  end
end
