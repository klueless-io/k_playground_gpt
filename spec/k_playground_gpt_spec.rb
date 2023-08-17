# frozen_string_literal: true

RSpec.describe KPlaygroundGpt do
  it 'has a version number' do
    expect(KPlaygroundGpt::VERSION).not_to be_nil
  end

  context 'when making local openai calls', :openai do
    it 'has an OpenAI Environment Variable' do
      expect(ENV.fetch('OPENAI_API_KEY', nil)).not_to be_nil
    end
  end
end
