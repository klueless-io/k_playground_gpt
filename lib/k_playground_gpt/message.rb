# frozen_string_literal: true

module KPlaygroundGpt
  # Chatbot conversation will store the conversational messages for a
  # chatbot session and also be able to merge in data from external source
  class Message
    attr_reader :role, :content, :key

    def initialize(role, content)
      @role = role
      @content = content
      @key = Digest::SHA1.hexdigest(content)
    end

    def openai_message
      {
        role: role,
        content: content
      }
    end
  end
end
