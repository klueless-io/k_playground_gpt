# frozen_string_literal: true

RSpec.describe KPlaygroundGpt do
  it 'has a version number' do
    expect(KPlaygroundGpt::VERSION).not_to be_nil
  end

  it 'has a standard error' do
    expect { raise KPlaygroundGpt::Error, 'some message' }
      .to raise_error('some message')
  end
end
