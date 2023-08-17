# frozen_string_literal: true

COMPLETION_MODELS = %w[ada babbage curie davinci].freeze

RSpec.describe 'Endpoints', :openai do
  let(:client) { OpenAI::Client.new }

  describe '.models' do
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

        L.json(response)
      end
    end
  end

  describe '.completions' do
    let(:prompt) { 'Once upon a time' }
    let(:max_tokens) { 5 }

    context 'with simple prompt' do
      COMPLETION_MODELS.each do |model|
        it "returns a completion (JSON) for model #{model}" do
          response = client.completions(parameters: { model: model, prompt: prompt, max_tokens: max_tokens })
          L.subheading model
          L.kv 'Prompt', prompt
          # L.json(response)

          sentence = "#{prompt}#{response['choices'][0]['text']}"
          L.kv('Sentence', sentence)

          L.section_heading 'Usage'

          L.kv 'Prompt tokens', response['usage']['prompt_tokens']
          L.kv 'Completion tokens', response['usage']['completion_tokens']
          L.kv 'Total tokens', response['usage']['total_tokens']
        end
      end
    end
  end
end
