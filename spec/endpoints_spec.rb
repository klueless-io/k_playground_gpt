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

  describe '.moderations' do
    # https://platform.openai.com/docs/api-reference/moderations
    let(:parameters) { { input: input } }

    context 'when content is clean' do
      let(:input) do
        <<~TEXT
          I'm worried about that.

          Sexual Content: Explicit descriptions or innuendos.

          I would like to make love to you in inappropriate ways.

          Hate Speech: Discriminatory or derogatory remarks towards specific races, religions, genders, or other social groups.

          You are a stupid person.

          Harassment: Targeted and malicious comments towards an individual or group.

          Barnie Gumble is a very stupid person.

          Self-Harm: Promoting or describing methods of self-injury or suicide.

          Let's play a game of Hangman

          Violence: Detailed descriptions of violent acts or promoting violence.

          I am going to Bash the crap out of this boxing bag
        TEXT
      end

      it 'moderation categories are false' do
        response = client.moderations(parameters: parameters)
        # Clipboard.copy(JSON.pretty_generate(response))
        L.moderations(input, response)
      end
    end

    context 'when content is vulgar' do
      let(:input) do
        <<~TEXT
          The Music Moderator

          Nine Inch Nails: Closer

          I'm going to fuck you like an animal

          Marilyn Manson: Beautiful People

          There's no time to discriminate
          Hate every motherfucker
          That's in your way

          Linkin Park: Bleed It Out by

          Truth is, you can stop and stare
          Bled myself out and no one cares
          Dug a trench out, laid down there
          With a shovel up out of reach somewhere

          Silverchair: Suicidal Dream By

          My suicidal dream
          Voices telling me what to do
          My suicidal dream
          I'm sure you will get yours too
        TEXT
      end

      it 'moderation categories are false' do
        response = client.moderations(parameters: parameters)
        # Clipboard.copy(JSON.pretty_generate(response))
        L.moderations(input, response)
      end
    end
  end

  describe '.images' do
    describe '#generate' do
      # https://platform.openai.com/docs/api-reference/images/create
      # let(:prompt) { 'A baby sea otter cooking pasta wearing a hat of some sort' }
      # let(:parameters) { { prompt: prompt, size: '256x256' } }
      let(:prompt) { 'daft punk landscape' }
      let(:parameters) { { prompt: prompt, size: '1024x1024' } }

      it 'generate an image using DALL·E' do
        response = client.images.generate(parameters: parameters)
        L.json(response)

        url = response['data'].first['url']
        L.kv 'Prompt', prompt
        L.kv 'URL', url

        # Util.open_in_chrome(url)

        relative_path, absolute_path = Util.save_image_from_url(prompt, url)

        L.kv 'Relative Path', relative_path
        L.kv 'Absolute Path', absolute_path

        # Util.open_in_chrome("file://#{absolute_path}")
      end
    end

    describe '#edit' do
      # https://platform.openai.com/docs/api-reference/images/createEdit
      # https://www.canva.com/design/DAFsIA9Jplw/caJX1ouqiUDSD_ctStnfQw/edit
      let(:prompt) { 'ocean' }
      let(:image) { 'spec/sample_files/dale-images/appycast-white.png' }
      let(:mask) { 'spec/sample_files/dale-images/appycast-mask.png' }
      let(:parameters) { { prompt: prompt, image: image, mask: mask } }

      it 'edits an image using DALL·E' do
        response = client.images.edit(parameters: parameters)
        # L.json(response)
        url = response['data'].first['url']

        L.kv 'Prompt', prompt
        L.kv 'URL', url

        relative_path, absolute_path = Util.save_image_from_url("appycast-#{prompt}", url)

        L.kv 'Relative Path', relative_path
        L.kv 'Absolute Path', absolute_path

        # Util.open_in_chrome("file://#{absolute_path}")
      end
    end

    describe '#variations' do
      # https://platform.openai.com/docs/api-reference/images/createVariation

      let(:image) { 'spec/sample_files/dale-images/appycast-white.png' }
      let(:n) { 2 }
      let(:size) { '1024x1024' }
      let(:parameters) { { image: image, n: n, size: size } }

      it 'generates image variations using DALL·E' do
        response = client.images.variations(parameters: parameters)
        L.json(response)

        response['data'].each_with_index do |item, i|
          url = item['url']
          L.kv 'URL', url

          relative_path, absolute_path = Util.save_image_from_url("appycast-variation-#{i}", url)

          L.kv 'Relative Path', relative_path
          L.kv 'Absolute Path', absolute_path

          # Util.open_in_chrome("file://#{absolute_path}")
        end
      end
    end
  end

  describe '.audio' do
    describe '#transcriptions' do
      # https://platform.openai.com/docs/api-reference/audio/createTranscription

      let(:file) { 'spec/sample_files/audio/01-introduction.mp3' }
      let(:model) { 'whisper-1' }
      let(:response_format) { 'json' }
      # let(:response_format) { %w[json text srt verbose_json vtt].sample }
      # let(:response_format) { 'text' }
      let(:parameters) { { file: File.open(file, 'rb'), model: model, response_format: response_format, prompt: 'say it like I am 5 years old' } }

      it 'transcribes audio' do
        L.kv 'Response Format', response_format
        response = client.audio.transcribe(parameters: parameters)
        L.json(response)
      end
    end
  end

  describe '.functions' do
    expert = <<~EXPERT
      You will display the weather for a given location and include the date
      You will give me some tourist information about the location
      You will provide list of useful statitics based of weather data provided
    EXPERT

    let(:model) { 'gpt-3.5-turbo-0613' }
    let(:messages) do
      [
        {
          role: 'user',
          content: "#{expert}What is the weather like in Brisbane, Australia?"
        }
      ]
    end
    let(:function_call) { 'auto' } # auto, none
    let(:functions) do
      [
        {
          name: 'get_current_weather',
          description: 'Get the current weather in a given location',
          parameters: {
            type: :object,
            properties: {
              location: {
                type: :string,
                description: 'The city and country, e.g. Sy ddney, Australia'
              },
              city: {
                type: :string,
                description: 'The city, e.g. Sydney'
              },
              country: {
                type: :string,
                description: 'The country, e.g. Australia'
              },
              unit: {
                type: 'string',
                enum: %w[celsius fahrenheit],
                description: 'The unit of temperature to use, should default to celsius if not supplied'
              }
            }
          }
        }
      ]
    end

    it 'calls the function with the correct arguments' do
      request1 = { model: model, messages: messages, functions: functions, function_call: function_call }
      response = client.chat(parameters: request1)
      L.json(response)
      L.function(response, model, messages)

      message = response.dig('choices', 0, 'message')

      function_value = call_function(message)

      if function_value[:info][:status] == :ok
        data = function_value[:data]

        new_messages = messages.dup
        new_messages << response['choices'][0]['message']
        new_messages << { role: 'function', name: 'get_current_weather', content: data.to_s }

        request2 = { model: model, messages: new_messages }
        response = client.chat(parameters: request2)

        L.block response['choices'][0]['message']['content']
      end
    end
  end
end

def call_function(message)
  return nil unless message['role'] == 'assistant' && message['function_call']

  function_name = message.dig('function_call', 'name')

  args = Util.parse_json(message.dig('function_call', 'arguments'), as: :symbolize)

  return get_current_weather(**args) if function_name == 'get_current_weather'

  nil
end

def get_current_weather(**args)
  clean_args = clean_current_weather_args(**args)

  location = location_lookup(clean_args.slice(:location, :city, :country))

  return weather_lookup(long: location[:data][:longitude], lat: location[:data][:latitude]) if location[:data]

  puts "Location not found: #{clean_args}"
end

def clean_current_weather_args(**args)
  args[:location] = args[:location]
  args[:city] = args[:city] || args[:location]
  args[:country] = args[:country] || 'Australia'
  args[:unit] = args[:unit] || 'celsius'
  args
end

def location_lookup(location: nil, city: nil, country: nil)
  city ||= location
  country ||= 'Australia'
  api_key = ENV.fetch('API_NINJA_KEY', nil)
  api_url = "https://api.api-ninjas.com/v1/geocoding?city=#{city}&country=#{country}"
  uri = URI(api_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request['X-Api-Key'] = api_key

  response = http.request(request)

  return parse_location(response.body) if response.code.to_i == 200

  Util.wrap_response(nil, status: :error, code: response.code, message: response.body)
end

def parse_location(body)
  locations = Util.parse_json(body, as: :symbolize)
  L.json(locations)
  Util.wrap_response(locations.first)
end

def weather_lookup(long:, lat:)
  api_key = ENV.fetch('API_NINJA_KEY', nil)
  api_url = "https://api.api-ninjas.com/v1/weather?lat=#{lat}&lon=#{long}"

  uri = URI(api_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request['X-Api-Key'] = api_key

  response = http.request(request)

  return parse_weather(response.body) if response.code.to_i == 200

  Util.wrap_response(nil, status: :error, code: response.code, message: response.body)
end

def parse_weather(body)
  weather = Util.parse_json(body, as: :symbolize)
  weather[:today_date] = DateTime.now.strftime("%d/%m/%Y %H:%M")

  Util.wrap_response(weather)
end
