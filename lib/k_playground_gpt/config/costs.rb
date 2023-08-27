# frozen_string_literal: true

module KPlaygroundGpt
  module Config
    # Reads the config file
    class Costs
      FILE_PATH = 'config/costs.json'

      def initialize
        @data = load_data
      end

      def lookup_by_model(model_name)
        @data.find { |entry| entry['model'] == model_name }
      end

      private

      def load_data
        JSON.parse(File.read(FILE_PATH))
      end
    end
  end
end
