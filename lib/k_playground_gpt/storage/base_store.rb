# frozen_string_literal: true

module KPlaygroundGpt
  module Storage
    # Abstract class for Chatbot storage implementations
    class BaseStore
      def read
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def write(conversation)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def open_in_editor
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
