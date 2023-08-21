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
  end
end
