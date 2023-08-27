# frozen_string_literal: true

module KPlaygroundGpt
  module Storage
    # Factory for creating storage implementations based on a class or symbol
    class StoreFactory
      STORE_MAPPINGS = {
        save_last_file: -> { FileStore.new('.last-chat.json') }
      }.freeze

      def self.build(store_identifier)
        return nil if store_identifier.nil?
        return store_identifier if store_identifier.is_a?(BaseStore)

        store_action = STORE_MAPPINGS[store_identifier] || store_identifier

        if store_action.respond_to?(:call)
          store_action.call
        elsif store_action.is_a?(Class)
          store_action.new
        else
          raise "Unsupported store identifier: #{store_identifier}"
        end
      end
    end
  end
end
