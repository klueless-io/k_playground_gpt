# frozen_string_literal: true

module DataHelper
  def deep_symbolize_keys(value)
    case value
    when Array
      value.map { |v| deep_symbolize_keys(v) }
    when Hash
      value.each_with_object({}) do |(key, v), result|
        new_key = begin
          key.to_sym
        rescue StandardError
          key
        end
        new_value = deep_symbolize_keys(v)
        result[new_key] = new_value
      end
    else
      value
    end
  end
end
