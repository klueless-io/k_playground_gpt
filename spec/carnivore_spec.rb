# frozen_string_literal: true

RSpec.describe 'Carnivore', :openai do
  let(:carnivore) { Carnivore.new }

  it 'should transfer the holding conversation to the target' do
    file = carnivore.transfer_holding_conversation_to_target

    # Open up in vscode in a new vscode window
    system("cursor #{file}")
  end

  it 'should create a zip of all conversations' do
    carnivore.archive_conversations
  end

  it 'should parse conversations from raw text to JSON' do
    carnivore.process_conversations_to_json
  end

end
