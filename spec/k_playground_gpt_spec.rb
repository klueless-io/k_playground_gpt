# frozen_string_literal: true

RSpec.describe KPlaygroundGpt do
  it 'has a version number' do
    expect(KPlaygroundGpt::VERSION).not_to be_nil
  end

  xit 'has an OpenAI Environment Variable' do
    expect(ENV.fetch('OPENAI_API_KEY', nil)).not_to be_nil
  end, 'Will not run integration test in CI'
end
