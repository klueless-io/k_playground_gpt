# frozen_string_literal: true

module KPlaygroundGpt
  module Storage
    # Read and write chat data to a file
    class FileStore < BaseStore
      attr_reader :filename

      def initialize(filename)
        @filename = filename
        super()
      end

      def read
        File.read(filename) if File.exist?(filename)
      end

      def write(conversation)
        File.write(filename, conversation)
      end

      def open_in_editor
        system("open #{filename}")
      end
    end
  end
end
