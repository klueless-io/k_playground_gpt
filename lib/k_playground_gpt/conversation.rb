# frozen_string_literal: true

module KPlaygroundGpt
  # Chatbot conversation will store the conversational messages for a
  # chatbot session and also be able to merge in data from external source
  class Conversation
    attr_reader :system_prompt

    def initialize
      @system_prompt = nil
      @conversation = []
    end

    def set_system_prompt(content)
      @system_prompt = content.nil? ? nil : Message.new(:system, content)
    end

    def system_prompt?
      !@system_prompt.nil?
    end

    def add_user(content)
      user = Message.new(:user, content)
      @conversation << user
      user
    end

    def add_assistant(content)
      assistant = Message.new(:assistant, content)
      @conversation << assistant
      assistant
    end

    # Messages are in the same format as the OpenAI API
    def messages
      sys_prompt = @system_prompt&.openai_message
      prompts = @conversation.map(&:openai_message)
      [sys_prompt, *prompts].compact
    end

    def to_h
      {
        system_prompt: @system_prompt.openai_message,
        conversation: @conversation.map(&:openai_message)
      }
    end
  end
end
