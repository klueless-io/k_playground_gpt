# frozen_string_literal: true

require_relative 'helpers'

module LogUsecases
  include ::Helpers

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
end
