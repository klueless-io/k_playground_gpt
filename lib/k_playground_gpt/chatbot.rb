# frozen_string_literal: true

module KPlaygroundGpt
  # https://chat.openai.com/c/0cd0f0f2-f798-427d-9160-0feea8a7d37d
  # Usage:
  #  conversation = KPlaygroundGpt::Chatbot
  #   .start(store: KPlaygroundGpt::Storage::FileStore.new('tmp/xmen.json'))
  #   .system_prompt('You are an expert in writing code for ChatGPT chatbots using ruby and rspec.')
  #   .chat
  #
  #  L.debug_chatbot chatbot, include_json: true
  #
  # KPlaygroundGpt::Chatbot
  #   .start(store: :save_last_file)
  #   .system_prompt('You are an expert in YouTube titles. Please wait for my question!')
  #   .bot("Sure, I'm here to help you with YouTube titles. What would you like to know?")
  #   .ask('Can you give me 10 YouTube titles for a video creating GPT Chatbots in Ruby?')
  #   .chat
  #
  #  L.debug_chatbot chatbot, include_json: true
  class Chatbot
    extend Forwardable

    # ChatGPT parameters
    attr_reader :model
    attr_reader :temperature
    attr_reader :max_tokens
    attr_reader :top_p
    attr_reader :frequency_penalty
    attr_reader :presence_penalty

    attr_reader :client
    attr_reader :store

    attr_reader :conversation
    attr_reader :chat_response

    def_delegator :conversation, :system_prompt?, :system_prompt?
    def_delegator :conversation, :messages, :messages

    DEFAULT_OPTIONS = {
      model: 'gpt-3.5-turbo',
      temperature: 0.7,
      max_tokens: 256,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0,
      store: nil
    }.freeze

    # The original initializer
    def initialize(**options)
      options = DEFAULT_OPTIONS.merge(options)

      @client = OpenAI::Client.new
      @model = options[:model]
      @temperature = options[:temperature]
      @max_tokens = options[:max_tokens]
      @top_p = options[:top_p]
      @frequency_penalty = options[:frequency_penalty]
      @presence_penalty = options[:presence_penalty]

      @store = Storage::StoreFactory.build(options[:store])
      @conversation = KPlaygroundGpt::Conversation.new
    end

    def self.start(options = {})
      new(options)
    end

    # DSL
    def chat
      @chat_response = @client.chat(parameters: parameters)

      save_to_store if store

      self
    end

    def system_prompt(content = nil)
      conversation.set_system_prompt(content)

      self
    end

    def ask(content)
      conversation.add_user(content)

      self
    end
    alias user ask

    def bot(content)
      conversation.add_assistant(content)
      self
    end
    alias assistant bot

    # State
    def response
      puts 'run chat first' if @chat_response.nil?

      @chat_response
    end

    def content
      response.dig('choices', 0, 'message', 'content')
    end

    def estimate_token_usage
      messages.sum { |message| OpenAI.rough_token_count(message[:content]) }
    end

    private

    def parameters
      {
        model: model,
        messages: messages,
        temperature: temperature,
        max_tokens: max_tokens,
        top_p: top_p,
        frequency_penalty: frequency_penalty,
        presence_penalty: presence_penalty
      }
    end

    def save_to_store
      json = JSON.pretty_generate(conversation.to_h)
      store.write(json)
    end
  end
end
