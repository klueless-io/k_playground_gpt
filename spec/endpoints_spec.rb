# frozen_string_literal: true

RSpec.describe 'Endpoints' do
  context 'when using models', :openai do
    OpenAI.configure do |config|
      config.access_token = ENV.fetch('OPENAI_API_KEY')
    end

    let(:client) { OpenAI::Client.new }

    describe '#list' do
      it 'returns a list of models (JSON)' do
        response = client.models.list

        puts JSON.pretty_generate(response)
      end

      it 'returns a list of models with just id and type' do
        response = client.models.list['data'].map { |entry| { id: entry['id'], type: entry['object'] } }

        tp response.sort_by { |entry| entry[:id] }
      end
    end
  end
end
