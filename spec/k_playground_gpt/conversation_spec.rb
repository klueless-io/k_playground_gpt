# frozen_string_literal: true

# require 'digest'

RSpec.describe KPlaygroundGpt::Conversation do
  subject(:conversation) { described_class.new }

  describe '#initialize' do
    it 'starts with no system prompt' do
      expect(conversation.instance_variable_get(:@system_prompt)).to be_nil
    end

    it 'initializes with an empty conversation array' do
      expect(conversation.instance_variable_get(:@conversation)).to eq([])
    end
  end

  describe '.messages' do
    subject { conversation.messages }

    it { is_expected.to eq([]) }

    context 'when system prompt provided' do
      before do
        conversation.set_system_prompt('You are a GPT-3 bot.')
      end

      it { is_expected.to include({ role: :system, content: 'You are a GPT-3 bot.' }) }
      it { expect(subject.count).to eq(1) }
    end

    context 'when system prompt and user message provided' do
      before do
        conversation.set_system_prompt('You are a GPT-3 bot.')
        conversation.add_user('Hello')
      end

      it { expect(subject.count).to eq(2) }

      it 'has expected messages' do
        expect(subject)
          .to include({ role: :system, content: 'You are a GPT-3 bot.' })
          .and include({ role: :user, content: 'Hello' })
      end
    end

    context 'when assistant message provided' do
      before do
        conversation.set_system_prompt('You are a GPT-3 bot.')
        conversation.add_user('Hello')
        conversation.add_assistant('Hi there!')
      end

      it { expect(subject.count).to eq(3) }

      it 'has expected messages' do
        expect(subject)
          .to include({ role: :system, content: 'You are a GPT-3 bot.' })
          .and include({ role: :user, content: 'Hello' })
          .and include({ role: :assistant, content: 'Hi there!' })
      end

      context 'when system prompt is updated' do
        before do
          conversation.set_system_prompt('You are a GPT-4 bot.')
        end

        it { expect(subject.count).to eq(3) }

        it 'has expected messages' do
          expect(subject)
            .to include({ role: :system, content: 'You are a GPT-4 bot.' })
            .and include({ role: :user, content: 'Hello' })
            .and include({ role: :assistant, content: 'Hi there!' })
        end
      end

      context 'when system prompt is removed' do
        before do
          conversation.set_system_prompt(nil)
        end

        it { expect(subject.count).to eq(2) }

        it 'has expected messages' do
          expect(subject)
            .to include({ role: :user, content: 'Hello' })
            .and include({ role: :assistant, content: 'Hi there!' })
        end
      end
    end
  end

  describe '#to_h' do
    subject { conversation.to_h }

    before do
      conversation.set_system_prompt('You are a GPT-3 bot.')
      conversation.add_user('Hello')
      conversation.add_assistant('Hi there!')
      conversation.add_user('What time is it?')
    end

    it 'returns a hash with system_prompt and conversation keys' do
      expected = {
        system_prompt: { role: :system, content: 'You are a GPT-3 bot.' },
        conversation: [
          { role: :user, content: 'Hello' },
          { role: :assistant, content: 'Hi there!' },
          { role: :user, content: 'What time is it?' }
        ]
      }

      expect(subject).to eq(expected)
    end
  end
end
