# frozen_string_literal: true

require 'net/http'
require 'fileutils'
require 'uri'

class Util

  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36'

  class << self
    def save_image_from_url(prompt, image_url)
      # Create a valid file name
      filename = prompt.gsub(/[^\w\-]+/, '_').downcase[0...100]

      # Destination
      relative_path = "spec/sample_files/dale-images/#{filename}.png"
      absolute_path = File.expand_path(relative_path)

      # Ensure the directory exists
      FileUtils.mkdir_p(File.dirname(relative_path))

      image_data = Net::HTTP.get(URI(image_url))

      File.binwrite(relative_path, image_data)

      [relative_path, absolute_path]
    end

    def open_in_chrome(url)
      system("open -a \"Google Chrome\" '#{url}'")
    end

    def parse_json(json, as: :hash)
      case as
      when :symbolize, :symbolize_names, :symbolize_keys
        JSON.parse(json, symbolize_names: true)
      when :deep_symbolize, :deep, :deep_symbolize_keys, :deep_symbolize_names
        data = JSON.parse(json, symbolize_names: true)
        deep_symbolize_keys(data)
      when :open_struct
        JSON.parse(json, object_class: OpenStruct)
      else
        JSON.parse(json)
      end
    end

    def deep_symbolize_keys(value)
      case value
      when Array
        value.map { |v| deep_symbolize_keys(v) }
      when Hash
        value.each_with_object({}) do |(key, v), result|
          new_key = begin
            key.to_sym
          rescue StandardError
            key
          end
          new_value = deep_symbolize_keys(v)
          result[new_key] = new_value
        end
      else
        value
      end
    end
  
    # {
    #   info: {
    #     status: :ok,                # or :error
    #     code: 200,                  # or any error code
    #     message: nil                # or "You screwed up"
    #   },
    #   data: {
    #     name: "Sydney",
    #     latitude: -33.8698439,
    #     longitude: 151.2082848,
    #     country: "AU",
    #     state: "New South Wales"
    #   }                             # or nil
    # }
    def wrap_response(data, status: :ok, code: 200, message: nil)
      {
        info: {
          status: status,
          code: code,
          message: message
        },
        data: data
      }
    end
    def wrap_response_error(code, message)
      wrap_response(nil, status: :error, code: code, message: message)
    end
  end
end
