# frozen_string_literal: true

require 'k_playground_gpt/version'

module KPlaygroundGpt
  # raise KPlaygroundGpt::Error, 'Sample message'
  Error = Class.new(StandardError)

  # Your code goes here...
end

if ENV.fetch('KLUE_DEBUG', 'false').downcase == 'true'
  namespace = 'KPlaygroundGpt::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_playground_gpt/version') }
  version   = KPlaygroundGpt::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end