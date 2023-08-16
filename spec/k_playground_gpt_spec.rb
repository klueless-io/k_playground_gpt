# frozen_string_literal: true

RSpec.describe KPlaygroundGpt do
  it 'has a version number' do
    expect(KPlaygroundGpt::VERSION).not_to be_nil
  end

  it 'has an OpenAI Environment Variable' do
    expect(ENV.fetch('OPENAI_API_KEY', nil)).not_to be_nil
    expect(ENV.fetch('OPENAI_API_KEY', nil)).to eq('xmen')
  end
end
