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

  context 'when pretty log messages are required' do
    it 'can print tagged messages' do
      Log.info 'some info message'
      Log.warn 'some warning message'
      Log.debug 'some debug message'
      Log.error 'some error message'
    end

    it 'can print key value pairs' do
      Log.kv('@AppyDave', 'Software Development using ChatGPT')
      Log.kv('@FliVideo', 'YouTube Automation')
      Log.kv('@WinningPrompts', 'Prompt Engineering')
      Log.kv('# of EndPoints', 8)
      Log.kv('# of Use Cases', 23)
    end

    it 'can print headings' do
      Log.heading('Heading')
      Log.subheading('Sub Heading')
      Log.section_heading('Section Heading')
    end
  end
end
