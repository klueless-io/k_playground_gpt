# frozen_string_literal: true

require 'openai'
require 'clipboard'
require_relative 'k_playground_gpt/version'
require_relative 'k_playground_gpt/config/costs'
require_relative 'k_playground_gpt/chatbot'
require_relative 'k_playground_gpt/conversation'
require_relative 'k_playground_gpt/message'
require_relative 'k_playground_gpt/storage/base_store'
require_relative 'k_playground_gpt/storage/file_store'
require_relative 'k_playground_gpt/storage/store_factory'

# The main module for the gem

module KPlaygroundGpt
  class Error < StandardError; end
  # Your code goes here...
end
