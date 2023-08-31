# frozen_string_literal: true

# Usage:
#  chatbot = KPlaygroundGpt::Chatbot
#   .start
#   .system_prompt('You are an expert in writing code for ChatGPT chatbots using ruby and rspec.')
#   .chat
# L.conversation chatbot
RSpec.describe KPlaygroundGpt::Chatbot, :openai do
  # let(:system_prompt) { 'You are an expert in writing code for ChatGPT chatbots using ruby and rspec.' }
  context 'when ChatBot does not remember chat history' do
    let(:chatbot) { described_class.start.system_prompt(system_prompt) }
    let(:system_prompt) { 'You are an expert in YouTube titles. Please wait for my question!' }

    context 'when ChatBot is YouTube title expert' do
      let(:sample_response_for_titles) do
        <<~TITLES
          Of course! Here are 10 YouTube title ideas for a video about creating GPT Chatbots in Ruby:

          1. "Building Powerful GPT Chatbots in Ruby: A Step-by-Step Guide"
          2. "Mastering GPT Chatbot Development with Ruby: From Basics to Advanced"
          3. "Creating Intelligent Chatbots using Ruby and GPT Technology"
          4. "Unlocking the Potential of GPT Chatbots in Ruby: A Comprehensive Tutorial"
          5. "Ruby Chatbot Development: Harnessing the Power of GPT for Natural Conversations"
          6. "Level Up Your Ruby Skills: Building AI-Powered GPT Chatbots"
          7. "Ruby Programming for Chatbot Enthusiasts: Exploring GPT-based Solutions"
          8. "Building Conversational AI with Ruby: Exploring GPT Chatbot Development"
          9. "Demystifying GPT Chatbots in Ruby: A Hands-On Tutorial for Beginners"
          10. "Taking Ruby Chatbot Development to the Next Level: Integrating GPT Technology"
          Feel free to customize or modify these titles to suit your specific video content and target audience.#{'        '}
        TITLES
      end

      context 'when only the system prompt is provided' do
        it 'returns information about what the ChatBot' do
          chatbot.chat

          L.debug_chatbot chatbot, include_json: true
        end
      end

      context 'when system prompt -> bot -> ask' do
        it 'returns information about what the ChatBot' do
          chatbot
            .bot("Sure, I'm here to help you with YouTube titles. What would you like to know?")
            .ask('Can you give me 10 YouTube titles for a video creating GPT Chatbots in Ruby?')
            .chat

          L.debug_chatbot chatbot, include_json: true
        end
      end

      context 'when system prompt -> bot -> ask -> bot -> ask' do
        it 'returns information about what the ChatBot' do
          chatbot
            .bot("Sure, I'm here to help you with YouTube titles. What would you like to know?")
            .ask('Can you give me 10 YouTube titles for a video creating GPT Chatbots in Ruby?')
            .bot(sample_response_for_titles)
            .ask('What title is the shortest?')
            .chat

          L.debug_chatbot chatbot, include_json: true
        end
      end

      context 'when system prompt -> bot -> ask -> bot -> ask -> ask again' do
        it 'returns information about what the ChatBot' do
          # SUCCESS: Answered both questions.
          chatbot
            .bot("Sure, I'm here to help you with YouTube titles. What would you like to know?")
            .ask('Can you give me 10 YouTube titles for a video creating GPT Chatbots in Ruby?')
            .bot(sample_response_for_titles)
            .ask('What title is the shortest?')
            .ask('What title is the best, and why do you think so?') # This worked
            .chat

          L.debug_chatbot chatbot, include_json: true
        end
      end

      context 'when system prompt -> bot -> ask -> bot -> ask -> ask again & again & again' do
        it 'returns information about what the ChatBot' do
          # FAILS: Only does the last question, missed the three others.
          chatbot
            .bot("Sure, I'm here to help you with YouTube titles. What would you like to know?")
            .ask('Can you give me 10 YouTube titles for a video creating GPT Chatbots in Ruby?')
            .bot(sample_response_for_titles)
            .ask('What title is the shortest?')
            .ask('What title is the best, and why do you think so?')
            .ask('Could you also give me the structure of a video that was 2 minutes long in a Markdown format?')
            .ask('Can you then write a script for a 2 minute video following the format you suggest')
            .chat

          L.debug_chatbot chatbot, include_json: true
        end
      end

      context 'when system prompt -> bot -> ask -> bot -> ask multiple questions' do
        it 'returns information about what the ChatBot' do
          # FAILS: Only does the last question
          multiple_questions = [
            'What title is the shortest?',
            'What title is the best, and why do you think so?',
            'Could you also give me the structure of a video that was 2 minutes long in a Markdown format?',
            'Can you then write a script for a 2 minute video following the format you suggest'
          ].join("\n")

          chatbot
            .bot("Sure, I'm here to help you with YouTube titles. What would you like to know?")
            .ask('Can you give me 10 YouTube titles for a video creating GPT Chatbots in Ruby?')
            .bot(sample_response_for_titles)
            .ask(multiple_questions)
            .chat

          L.debug_chatbot chatbot, include_json: true
        end
      end
    end
  end

  context 'when ChatBot stores chat history in a file' do
    it 'stores the chat history in a configured file' do
      chatbot = described_class
                .start(store: KPlaygroundGpt::Storage::FileStore.new('tmp/xmen.json'))
                .system_prompt('You are an expert in YouTube titles. Please wait for my question!')
                .bot("Sure, I'm here to help you with YouTube titles. What would you like to know?")
                .ask('Can you give me 10 YouTube titles for a video creating GPT Chatbots in Ruby?')
                .chat

      # chatbot.store.open

      L.debug_chatbot chatbot, include_json: true
    end

    it 'stores the chat history in the default file' do
      chatbot = described_class
                .start(store: :save_default_file)
                .system_prompt('You are an expert in YouTube titles. Please wait for my question!')
                .bot("Sure, I'm here to help you with YouTube titles. What would you like to know?")
                .ask('Can you give me 10 YouTube titles for a video creating GPT Chatbots in Ruby?')
                .chat

      chatbot.store.open_in_editor

      L.debug_chatbot chatbot, include_json: true
    end
  end

  # Potato Prompt: https://www.youtube.com/watch?v=5otmxZGyj-w
  # Perfect Prompt Formula: https://www.youtube.com/watch?v=jC4v5AS4RIM
  # Proof Read: https://chat.openai.com/c/1c690acc-a2fd-4f1c-b48e-ee45b5cf72c4
end
