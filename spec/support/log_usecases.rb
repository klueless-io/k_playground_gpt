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

  def function(response, model, messages)
    L.json(response)
    L.kv 'Model', model
    L.kv 'Messages', messages

    usage(response)

    L.section_heading 'Response Meta'
    L.json(response['choices'][0])
  end

  def usage(response)
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
end
