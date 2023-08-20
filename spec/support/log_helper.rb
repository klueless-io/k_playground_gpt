# frozen_string_literal: true

class LogHelper
  COLORS = {
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34,
    purple: 35,
    cyan: 36,
    grey: 37
  }.freeze

  BG_COLORS = {
    bg_red: 41,
    bg_green: 42,
    bg_yellow: 43,
    bg_blue: 44,
    bg_purple: 45,
    bg_cyan: 46,
    bg_grey: 47
  }.freeze

  class << self
    COLORS.each do |color, code|
      define_method(color) do |value|
        "\033[#{code}m#{value}\033[0m"
      end
    end

    BG_COLORS.each do |color, code|
      define_method(color) do |value|
        "\033[#{code}m#{value}\033[0m"
      end
    end

    def kv(key, value, key_width = 30)
      "#{green(key.to_s.ljust(key_width))}: #{value}"
    end

    def line(size = 70, character = '=')
      green(character * size)
    end

    def heading(heading, size = 70)
      [line(size), heading, line(size)]
    end

    def subheading(heading, size = 70)
      [line(size, '-'), heading, line(size, '-')]
    end

    def section_heading(heading, size = 70)
      brace_open = green('[ ')
      brace_close = green(' ]')
      line_length = size - heading.length - 4
      line_content = line_length.positive? ? line(line_length, '-') : ''

      "#{brace_open}#{heading}#{brace_close}#{green(line_content)}"
    end

    def block(messages, include_line: true, title: nil)
      result = []

      result << line if include_line
      result.push(title, line(70, '-')) if title
      result.concat(Array(messages))

      result << line if include_line

      result
    end
  end
end
