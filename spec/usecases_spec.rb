# frozen_string_literal: true

COMPLETION_MODELS = %w[ada babbage curie davinci].freeze
CHAT_MODELS = %w[gpt-3.5-turbo gpt-4].freeze

RSpec.describe 'UseCases', :openai do
  let(:client) { OpenAI::Client.new }

end
