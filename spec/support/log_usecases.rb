# frozen_string_literal: true

module LogUsecases
  def moderations(data)
    categories = data['categories']
    category_scores = data['category_scores']
    categories_list = [
      'sexual', 'hate', 'harassment', 'self-harm', 'sexual/minors', 'hate/threatening',
      'violence/graphic', 'self-harm/intent', 'self-harm/instructions',
      'harassment/threatening', 'violence'
    ]

    categories_list.each do |category|
      formatted_key = category.split('/').map(&:capitalize).join(' ')
      L.kv formatted_key, "#{categories[category].to_s.ljust(6)}: #{category_scores[category]}"
    end

    # L.kv 'Sexual', "#{categories['sexual'].to_s.ljust(6)}: #{category_scores['sexual']}"
    # L.kv 'Hate', "#{categories['hate'].to_s.ljust(6)}: #{category_scores['hate']}"
    # L.kv 'Harassment', "#{categories['harassment'].to_s.ljust(6)}: #{category_scores['harassment']}"
    # L.kv 'Self-harm', "#{categories['self-harm'].to_s.ljust(6)}: #{category_scores['self-harm']}"
    # L.kv 'Sexual/minors', "#{categories['sexual/minors'].to_s.ljust(6)}: #{category_scores['sexual/minors']}"
    # L.kv 'Hate/threatening', "#{categories['hate/threatening'].to_s.ljust(6)}: #{category_scores['hate/threatening']}"
    # L.kv 'Violence/graphic', "#{categories['violence/graphic'].to_s.ljust(6)}: #{category_scores['violence/graphic']}"
    # L.kv 'Self-harm/intent', "#{categories['self-harm/intent'].to_s.ljust(6)}: #{category_scores['self-harm/intent']}"
    # L.kv 'Self-harm/instructions', "#{categories['self-harm/instructions'].to_s.ljust(6)}: #{category_scores['self-harm/instructions']}"
    # L.kv 'Harassment/threatening', "#{categories['harassment/threatening'].to_s.ljust(6)}: #{category_scores['harassment/threatening']}"
    # L.kv 'Violence', "#{categories['violence'].to_s.ljust(6)}: #{category_scores['violence']}"
  end
end
