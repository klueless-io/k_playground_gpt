# frozen_string_literal: true

COMPLETION_MODELS = %w[ada babbage curie davinci].freeze
CHAT_MODELS = %w[gpt-3.5-turbo gpt-4].freeze

RSpec.describe 'Endpoints', :openai do
  let(:client) { OpenAI::Client.new }

  describe '.models' do
    describe '#list' do
      # https://platform.openai.com/docs/api-reference/models/list
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
      # https://platform.openai.com/docs/api-reference/models/retrieve
      let(:model_id) { 'gpt-3.5-turbo' }

      it 'returns a model (JSON)' do
        response = client.models.retrieve(id: model_id)

        L.json(response)
      end
    end
  end

  describe '.completions' do
    # https://platform.openai.com/docs/api-reference/completions
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

          L.warn 'Completions is a legacy endpoint and will be removed in the future. Use the "Chat" endpoint instead.'
        end
      end
    end
  end

  describe '.edits' do
    # https://platform.openai.com/docs/api-reference/edits
    let(:model) { 'text-davinci-edit-001' }
    let(:parameters) { { model: model, input: prompt, instruction: instruction } }

    context 'when fixing spelling mistakes' do
      let(:prompt) { 'What day of the wek is it? If too bouys were talking to gurls' }
      let(:instruction) { 'Fix the spelling and grammar mistakes' }

      it 'returns edited response' do
        response = client.edits(parameters: parameters)

        L.kv 'Prompt', prompt
        L.kv 'Instruction', instruction
        L.kv 'Edited text', response['choices'][0]['text']

        L.section_heading 'Usage'

        L.kv 'Prompt tokens', response['usage']['prompt_tokens']
        L.kv 'Completion tokens', response['usage']['completion_tokens']
        L.kv 'Total tokens', response['usage']['total_tokens']

        L.warn 'Edits is a legacy endpoint and will be removed in the future. Use the "Chat" endpoint instead.'
      end
    end

    context 'when fixing misquotes' do
      let(:prompt) { 'The quick brown fox jumped over the lazy cat' }
      let(:instruction) { 'Fix misquotations' }

      5.times do
        it 'returns edited response' do
          response = client.edits(parameters: parameters)

          L.kv 'Prompt', prompt
          L.kv 'Instruction', instruction
          L.kv 'Edited text', response['choices'][0]['text']

          L.section_heading 'Usage'

          L.kv 'Prompt tokens', response['usage']['prompt_tokens']
          L.kv 'Completion tokens', response['usage']['completion_tokens']
          L.kv 'Total tokens', response['usage']['total_tokens']

          L.warn 'Edits is a legacy endpoint and will be removed in the future. Use the "Chat" endpoint instead.'
        end
      end
    end
  end

  describe '.chat' do
    let(:model) { CHAT_MODELS.sample } # gpt-3.5-turbo, gpt-4
    let(:messages) do
      [
        { role: 'system', content: system_prompt },
        { role: 'user', content: user_prompt }
      ]
    end
    let(:temperature) { 0.7 }
    let(:parameters) { { model: model, messages: messages, temperature: temperature } }

    context 'when chatting with a YouTube title expert' do
      let(:system_prompt) { 'You are an expert in YouTube title creation' }
      let(:user_prompt) { 'I am creating a video on How I used GPT to invent a programming language' }

      it 'returns a text response' do
        response = client.chat(parameters: parameters)

        L.kv 'Model', model
        L.kv 'Messages', messages
        L.kv 'Temperature', temperature
        L.block response['choices'][0]['message']['content']

        L.section_heading 'Usage'

        L.kv 'Prompt tokens', response['usage']['prompt_tokens']
        L.kv 'Completion tokens', response['usage']['completion_tokens']
        L.kv 'Total tokens', response['usage']['total_tokens']
      end
    end
  end

  describe '.embeddings' do
    # https://platform.openai.com/docs/models/embeddings
    # https://platform.openai.com/docs/guides/embeddings
    let(:model) { 'text-embedding-ada-002' }
    let(:input) { 'The food was delicious and the waiter' }
    let(:parameters) { { model: model, input: input } }

    it 'returns embeddings' do
      response = client.embeddings(parameters: parameters)
      L.json(response)

      L.kv 'Model', model
      L.kv 'Input', input
      L.block response.to_h['data'][0]['embedding'].first(10), title: 'First 10 Embeddings'
      L.kv 'Embedding count', response.to_h['data'][0]['embedding'].count
      # Smaller embedding size. The new embeddings have only 1536 dimensions, one-eighth the size of davinci-001 embeddings,
      # making the new embeddings more cost effective in working with vector databases.

      L.section_heading 'Usage'

      L.kv 'Prompt tokens', response['usage']['prompt_tokens']
      L.kv 'Total tokens', response['usage']['total_tokens']
    end
  end

  # Later on we will use this to create a DB driven search engine
  # Using PostgreSql to store embeddings: https://supabase.com/blog/openai-embeddings-postgres-vector

  context 'when JSONL file is needed' do
    it 'make jsonl file' do
      text_file = 'spec/sample_files/color-poems.txt'
      jsonl_file = 'spec/sample_files/color-poems.jsonl'
      Jsonl.text_file_to_jsonl_file(text_file, jsonl_file)
    end
  end

  describe '.files' do
    describe '#list' do
      # https://platform.openai.com/docs/api-reference/files/list
      it 'returns a list of files (JSON)' do
        response = client.files.list['data']

        # L.json(response)
        tp response
      end
    end

    describe '#upload' do
      let(:file) { 'spec/sample_files/color-poems.jsonl' }
      # let(:file) { 'spec/sample_files/qa-examples.jsonl' }
      let(:parameters) { { file: file, purpose: 'fine-tune' } }

      it 'uploads a file (JSON)' do
        response = client.files.upload(parameters: parameters)

        L.json(response)
      end
    end

    describe '#retrieve' do
      # https://platform.openai.com/docs/api-reference/files/retrieve
      let(:file_id) { 'file-xOVj8XkQSVutbKZgLKQFzIfI' }

      it 'returns a file (JSON)' do
        response = client.files.retrieve(id: file_id)

        L.json(response)
      end
    end

    describe '#content' do
      # https://platform.openai.com/docs/api-reference/files/content
      let(:file_id) { 'file-xOVj8XkQSVutbKZgLKQFzIfI' }
      # let(:file_id) { 'file-kwFLLjnBExa5UBvqrwDcecz9' }

      it 'returns a file (JSON)' do
        response = client.files.content(id: file_id)

        L.json(response)
      end
    end

    describe '#delete' do
      # https://platform.openai.com/docs/api-reference/files/delete
      let(:file_id) { 'file-qLOIww82Sv2Z8YHEF7zVHcOV' }

      it 'deletes a file (JSON)' do
        response = client.files.delete(id: file_id)

        L.json(response)
      end
    end
  end

  # class Finetunes
  #   def list
  #     OpenAI::Client.get(path: "/fine-tunes")
  #   end

  #   def create(parameters: {})
  #     OpenAI::Client.json_post(path: "/fine-tunes", parameters: parameters)
  #   end

  #   def retrieve(id:)
  #     OpenAI::Client.get(path: "/fine-tunes/#{id}")
  #   end

  #   def cancel(id:)
  #     OpenAI::Client.multipart_post(path: "/fine-tunes/#{id}/cancel")
  #   end

  #   def events(id:)
  #     OpenAI::Client.get(path: "/fine-tunes/#{id}/events")
  #   end

  #   def delete(fine_tuned_model:)
  #     if fine_tuned_model.start_with?("ft-")
  #       raise ArgumentError, "Please give a fine_tuned_model name, not a fine-tune ID"
  #     end

  #     OpenAI::Client.delete(path: "/models/#{fine_tuned_model}")
  #   end
  # end

  describe '.finetunes' do
    describe '#list' do
      # https://platform.openai.com/docs/api-reference/fine-tunes/list
      it 'returns a list of fine-tunes (JSON)' do
        response = client.finetunes.list['data']
        L.json(response)

        items = response.map { |item| OpenStruct.new(item) }
        tp items, :id, :status, :model, :fine_tuned_model, 'training_files.filename', 'training_files.status'
      end
    end

    describe '#create' do
      # https://platform.openai.com/docs/api-reference/fine-tunes/create
      # https://platform.openai.com/docs/guides/fine-tuning
      let(:file_id) { 'file-kwFLLjnBExa5UBvqrwDcecz9' }
      let(:parameters) { { training_file: file_id, model: 'davinci' } } # model: 'gpt-4'

      it 'creates a fine-tune (JSON)' do
        response = client.finetunes.create(parameters: parameters)

        L.json(response)
      end
    end

    context 'with fine-tune id' do
      let(:fine_tune_id) { 'ft-z07UDvI1zLgnXt1RF5WZ9mdL' }

      describe '#retrieve' do
        # https://platform.openai.com/docs/api-reference/fine-tunes/retrieve
        it 'returns a fine-tune (JSON)' do
          response = client.finetunes.retrieve(id: fine_tune_id)

          L.json(response)
        end
      end

      describe '#cancel' do
        # https://platform.openai.com/docs/api-reference/fine-tunes/cancel
        it 'cancels a fine-tune (JSON)' do
          response = client.finetunes.cancel(id: fine_tune_id)

          L.json(response)
        end
      end

      describe '#events' do
        # https://platform.openai.com/docs/api-reference/fine-tunes/events
        it 'returns a fine-tune (JSON)' do
          response = client.finetunes.events(id: fine_tune_id)

          L.json(response)
        end
      end
    end

    describe '#delete' do
      # https://platform.openai.com/docs/api-reference/fine-tunes/delete
      let(:fine_tuned_model) { 'davinci:ft-print-speak-2023-08-18-08-34-12' }

      it 'deletes a fine-tune (JSON)' do
        response = client.finetunes.delete(fine_tuned_model: fine_tuned_model)

        L.json(response)
      end
    end
  end
end
