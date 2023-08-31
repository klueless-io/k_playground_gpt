# frozen_string_literal: true

module LogUsecases
  def moderations(input, moderation_response)
    categories = moderation_response['results'].first['categories']
    category_scores = moderation_response['results'].first['category_scores']
    categories_list = [
      'sexual', 'hate', 'harassment', 'self-harm', 'sexual/minors', 'hate/threatening',
      'violence/graphic', 'self-harm/intent', 'self-harm/instructions',
      'harassment/threatening', 'violence'
    ]

    L.kv 'Input', input
    L.kv 'Flagged', moderation_response['results'].first['flagged']

    categories_list.each do |category|
      formatted_key = category.split('/').map(&:capitalize).join(' ')
      label = categories[category].to_s.ljust(6)
      value = format('%.10f', category_scores[category])
      L.kv formatted_key, "#{label}: #{value}"
    end
  end

  def detailed_header(response)
    return if response.nil?
    L.kv 'Model', response['model']
    L.kv 'Id', response['id']
    L.kv 'Object', response['object']
    L.kv 'Created', response['created']
    L.kv 'Finished Reason', response['choices'][0]['finish_reason']
    # L.kv 'Content', response['choices'][0]['message']['content'][0..100]
  end

  def function(response, model, messages)
    L.json(response)
    L.kv 'Model', model
    L.kv 'Messages', messages

    usage(response)

    L.section_heading 'Response Meta'
    L.json(response['choices'][0])
  end

  def usage(response)
    return if response.nil?

    usage = response['usage']

    return data_not_available('usage') if usage.nil?

    L.section_heading 'Usage'
    L.kv 'Prompt tokens', usage['prompt_tokens']
    L.kv 'Completion tokens', usage['completion_tokens']
    L.kv 'Total tokens', usage['total_tokens']
  end

  def data_not_available(key)
    L.section_heading 'Data not available'
    L.kv 'Reason', "The #{key} data is not available in this response."
  end

  def conversation(chat)
    L.section_heading 'Chat Conversation'

    L.warn chat.system_prompt
    L.block chat.content
    L.kv 'Model requested', chat.model
    L.kv 'Temperature', chat.temperature
    L.detailed_header chat.response
    L.usage chat.response
    L.kv 'Prompt tokens estimated', chat.rough_token_usage
  end

  # rubocop:disable Metrics/AbcSize
  def debug_chatbot(chatbot, include_json: false)
    L.json chatbot.chat_response if include_json
    L.heading 'Chatbot Debug'

    L.section_heading 'Parameters'
    L.kv 'Model', chatbot.model
    L.kv 'Temperature', chatbot.temperature
    L.kv 'Max tokens', chatbot.max_tokens
    L.kv 'Top P', chatbot.top_p
    L.kv 'Frequency penalty', chatbot.frequency_penalty
    L.kv 'Presence penalty', chatbot.presence_penalty

    L.section_heading 'Response Meta'
    L.detailed_header chatbot.response
    L.usage chatbot.response

    L.section_heading 'Message Stream'
    L.kv 'System prompt?', chatbot.system_prompt?

    L.warn chatbot.conversation.system_prompt.content if chatbot.conversation.system_prompt?
    tp chatbot.messages, :role, { content: { width: 80 } }

    L.block chatbot.content, title: 'Chatbot Response'
  end
  # rubocop:enable Metrics/AbcSize
end
