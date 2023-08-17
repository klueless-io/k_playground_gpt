# frozen_string_literal: true

require 'pry'
require 'bundler/setup'
require 'simplecov'

SimpleCov.start

require 'clipboard'
require 'table_print'
require 'k_playground_gpt'

require 'dotenv'
ENV.delete('OPENAI_API_KEY')
Dotenv.load('.env.development')

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  config.filter_run_when_matching :focus
  config.filter_run_excluding openai: true if ENV['CI'] # Open AI: DevOnly CI is set in Github Actions

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY', 'sk-1234567890')
end
