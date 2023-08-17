# frozen_string_literal: true

RSpec.describe 'Endpoints' do
  context 'when using models', :openai do
    OpenAI.configure do |config|
      config.access_token = ENV.fetch('OPENAI_API_KEY', 'sk-1234567890')
    end

    let(:client) { OpenAI::Client.new }

    describe '#list' do
      it 'returns a list of models (JSON)' do
        response = client.models.list['data'].select { |entry| entry['id'] == 'gpt-3.5-turbo' }

        puts JSON.pretty_generate(response)
      end

      it 'returns a list of models with just id and type' do
        response = client
                   .models.list['data']
                   .map { |entry| { id: entry['id'], type: entry['object'], fine_tunable: entry['permission'][0]['allow_fine_tuning'] } }

        puts
        tp response.sort_by { |entry| entry[:id] }
      end
    end

    describe '#retrieve' do
      let(:model_id) { 'gpt-3.5-turbo' }

      it 'returns a model (JSON)' do
        response = client.models.retrieve(id: model_id)

        puts JSON.pretty_generate(response)
      end
    end
  end
end
