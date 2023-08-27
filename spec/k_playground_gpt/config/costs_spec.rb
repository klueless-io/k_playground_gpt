# frozen_string_literal: true

RSpec.describe KPlaygroundGpt::Config::Costs do
  let(:model_consts) { described_class.new }

  describe '#lookup_by_model' do
    context 'when deprecated model data exists' do
      # https://platform.openai.com/docs/deprecations/
      it 'returns the correct data for text-ada-001' do
        result = model_consts.lookup_by_model('text-ada-001')
        expect(result).to eq({
                               'shutdown_date' => '2024-01-04',
                               'model' => 'text-ada-001',
                               'combined' => '0.0004',
                               'input' => '',
                               'output' => '',
                               'training' => '',
                               'unit' => '1K tokens',
                               'recommended_replacement' => 'gpt-3.5-turbo-instruct'
                             })
      end
    end

    context 'when new model data exists' do
      # THESE NEED TO BE RENAMED TO MATCH THE NEW MODEL NAMES
      it 'returns the correct data for GPT-4-8K context' do
        result = model_consts.lookup_by_model('GPT-4-8K context')
        expect(result).to eq({
                               'model' => 'GPT-4-8K context',
                               'combined' => '',
                               'input' => '0.03',
                               'output' => '0.06',
                               'training' => '',
                               'unit' => '1K tokens',
                               'recommended_replacement' => ''
                             })
      end
    end

    context 'when fine-tune model data exists' do
      # THESE NEED TO BE RENAMED TO MATCH THE NEW MODEL NAMES
      it 'returns the correct data for babbage-002' do
        result = model_consts.lookup_by_model('babbage-002')
        expect(result).to eq({
                               'model' => 'babbage-002',
                               'combined' => '0.0004',
                               'input' => '0.0016',
                               'output' => '0.0016',
                               'training' => '0.0016',
                               'unit' => '1K tokens',
                               'recommended_replacement' => ''
                             })
      end
    end

    context 'when the model does not exist' do
      it 'returns nil for a nonexistent model' do
        result = model_consts.lookup_by_model('nonexistent-model')
        expect(result).to be_nil
      end
    end
  end
end
