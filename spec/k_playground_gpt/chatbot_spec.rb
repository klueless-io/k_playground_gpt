# frozen_string_literal: true

RSpec.describe KPlaygroundGpt::Chatbot do
  let(:system_prompt) { 'You are an expert in writing code for ChatGPT chatbots using ruby and rspec.' }
  let(:model) { 'gpt-3.5-turbo' }
  let(:temperature) { '0.7' }

  let(:chatbot) { described_class.new(model: model, temperature: temperature) }

  def mock_message(role, content)
    KPlaygroundGpt::Conversation.message(role, content)
  end

  describe '#initialize' do
    context 'when common parameters provided' do
      let(:chatbot) do
        described_class.new(model: model, temperature: temperature, max_tokens: max_tokens, top_p: top_p, frequency_penalty: frequency_penalty,
                            presence_penalty: presence_penalty)
      end

      let(:model) { 'awesome-model' }
      let(:temperature) { 0.555 }
      let(:max_tokens) { 300 }
      let(:top_p) { 0.72 }
      let(:frequency_penalty) { 0.39 }
      let(:presence_penalty) { 0.11 }

      context 'when has client' do
        subject { chatbot.client }

        it { is_expected.to be_a OpenAI::Client }
      end

      context 'when has model' do
        subject { chatbot.model }

        it { is_expected.to eq model }
      end

      context 'when has temperature' do
        subject { chatbot.temperature }

        it { is_expected.to eq temperature }
      end

      context 'when has max_tokens' do
        subject { chatbot.max_tokens }

        it { is_expected.to eq 300 }
      end

      context 'when has top_p' do
        subject { chatbot.top_p }

        it { is_expected.to eq 0.72 }
      end

      context 'when has frequency_penalty' do
        subject { chatbot.frequency_penalty }

        it { is_expected.to eq 0.39 }
      end

      context 'when has presence_penalty' do
        subject { chatbot.presence_penalty }

        it { is_expected.to eq 0.11 }
      end
    end

    context 'when no parameters provided' do
      let(:chatbot) { described_class.new }

      context 'when has client' do
        subject { chatbot.client }

        it { is_expected.to be_a OpenAI::Client }
      end

      context 'when has model' do
        subject { chatbot.model }

        it { is_expected.to eq 'gpt-3.5-turbo' }
      end

      context 'when has temperature' do
        subject { chatbot.temperature }

        it { is_expected.to eq 0.7 }
      end

      context 'when has max_tokens' do
        subject { chatbot.max_tokens }

        it { is_expected.to eq 256 }
      end

      context 'when has top_p' do
        subject { chatbot.top_p }

        it { is_expected.to eq 1 }
      end

      context 'when has frequency_penalty' do
        subject { chatbot.frequency_penalty }

        it { is_expected.to eq 0.0 }
      end

      context 'when has presence_penalty' do
        subject { chatbot.presence_penalty }

        it { is_expected.to eq 0.0 }
      end
    end

    describe '#start (DSL)' do
      subject { described_class.start }

      it { is_expected.to be_a described_class }
    end
  end

  describe '#chat' do
    let(:chatty) { chatbot.chat }
    let(:some_response) do
      {
        'id' => 'WQYn',
        'object' => 'chat.completion',
        'created' => 1_692_916_177,
        'model' => 'gpt-3.5-turbo-0613',
        'choices' =>
         [{ 'index' => 0,
            'message' => { 'role' => 'assistant', 'content' => expected_content },
            'finish_reason' => 'stop' }],
        'usage' => { 'prompt_tokens' => 3, 'completion_tokens' => 5, 'total_tokens' => 8 }
      }
    end
    let(:expected_content) { 'some content' }

    before do
      allow(chatbot.client).to receive(:chat).and_return(some_response)
    end

    context 'when no questions sked' do
      describe '.response' do
        subject { chatty.response }

        it { is_expected.to eq some_response }
      end

      describe '.content' do
        subject { chatty.content }

        it { is_expected.to eq expected_content }
      end
    end

    # context 'when writing a conversation to a data store' do
    #   let(:store) { FakeStore.new }
    #   let(:chatbot) { described_class.start(store: store) }

    #   subject { chatbot.chat }

    #   fit 'writes to the store' do
    #     expect { subject }.to change { store.internal_data }.from(nil).to([{ role: 'system', content: nil }])
    #   end
    # end
  end

  describe '.messages' do
    subject { chatbot.messages }

    it 'has system prompt' do
      chatbot.system_prompt('You are an expert in XYZ')

      expect(subject).to include({ role: :system, content: 'You are an expert in XYZ' })
    end

    it 'has system prompt and user questions' do
      chatbot.system_prompt('You are an expert in XYZ').ask('some question')

      expect(subject)
        .to include({ role: :system, content: 'You are an expert in XYZ' })
        .and include({ role: :user, content: 'some question' })
    end

    it 'has system prompt, user questions, and bot answers' do
      chatbot.system_prompt('You are an expert in XYZ').ask('some question').bot('some answer')

      expect(subject)
        .to include({ role: :system, content: 'You are an expert in XYZ' })
        .and include({ role: :user, content: 'some question' })
        .and include({ role: :assistant, content: 'some answer' })
    end
  end

  # State
  describe '.system_prompt?' do
    subject { chatbot.system_prompt? }

    context 'when system_prompt is nil' do
      let(:system_prompt) { nil }

      it { is_expected.to be false }
    end

    context 'when system_prompt is not nil' do
      before { chatbot.system_prompt('You are an expert in XYZ') }

      it { is_expected.to be true }
    end
  end

  describe '#estimate_token_usage' do
    subject { chatbot.estimate_token_usage }

    context 'with system_prompt' do
      before { chatbot.system_prompt('here are some words') }

      it { is_expected.to eq 5 }

      context 'with user question' do
        before { chatbot.ask('some other words') }

        it { is_expected.to eq 9 }

        context 'with bot answer' do
          before { chatbot.bot('And more') }

          it { is_expected.to eq 11 }
        end
      end
    end
  end
end
