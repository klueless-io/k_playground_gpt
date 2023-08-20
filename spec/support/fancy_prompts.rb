# frozen_string_literal: true

class FancyPrompts
  def self.documentary_titles(mamals)
    client = OpenAI::Client.new
    mamals.each do |mamal|
      user_prompt = "Can I get 3 titles for a documentary on #{mamal}?"
      parameters = {
        model: 'gpt-4',
        messages: [
          { role: 'system', content: 'You are an expert in writing documantary titles for David Attenborough that people want click and watch' },
          { role: 'user', content: user_prompt }
        ],
        temperature: 0.7,
        max_tokens: 128
      }
      response = client.chat(parameters: parameters)

      # L.kv 'Model', model
      L.block response['choices'][0]['message']['content'], title: user_prompt
    end
  end
end
