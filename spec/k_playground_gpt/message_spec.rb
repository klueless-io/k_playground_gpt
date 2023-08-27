# frozen_string_literal: true

RSpec.describe KPlaygroundGpt::Message do
  let(:role) { 'user' }
  let(:content) { 'Hello, GPT!' }
  let(:message) { described_class.new(role, content) }

  describe '#initialize' do
    it 'assigns role, content, and computes a key' do
      expect(message.role).to eq(role)
      expect(message.content).to eq(content)
      expect(message.key).to eq(Digest::SHA1.hexdigest(content))
    end
  end

  describe '#openai_message' do
    it 'returns a hash with role and content' do
      expect(message.openai_message).to eq({
                                             role: role,
                                             content: content
                                           })
    end
  end
end
