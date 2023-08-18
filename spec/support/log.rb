# frozen_string_literal: true

class LogFormatter < Logger::Formatter
  SEVERITY_TO_COLOR_MAP = {
    'DEBUG' => '34',
    'INFO' => '32',
    'WARN' => '33',
    'ERROR' => '31',
    'FATAL' => '37'
  }.freeze

  def call(severity, _timestamp, _prog_name, msg)
    message = format_msg(msg)
    return format("%<message>s\n", message: message) if suppress_severity?

    format("%<severity>s %<message>s\n", severity: format_severity(severity), message: message)
  end

  private

  def format_msg(msg)
    msg.is_a?(String) ? msg : msg.inspect
  end

  def format_severity(severity)
    color = SEVERITY_TO_COLOR_MAP[severity.upcase]
    format("\033[#{color}m%<severity>-5.5s\033[0m", severity: severity)
  end

  def suppress_severity?
    Thread.current[:log_formatter_suppress_severity] || false
  end
end

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

class LogUtil
  class << self
    attr_accessor :logger

    def default_logger
      @default_logger ||= begin
        logger = Logger.new($stdout)
        logger.level = Logger::DEBUG
        logger.formatter = LogFormatter.new
        logger
      end
    end
  end

  LOG_METHODS = %i[debug info warn error fatal].freeze

  LOG_METHODS.each do |method|
    define_method(method) do |value|
      @logger.public_send(method, value)
    end
  end

  def initialize(logger = self.class.default_logger)
    @logger = logger
  end

  def kv(key, value, key_width = 30)
    info(LogHelper.kv(key, value, key_width))
  end

  def line(size = 70, character: '=')
    info(LogHelper.line(size, character))
  end

  def heading(heading, size = 70)
    multi_lines(LogHelper.heading(heading, size))
  end

  def subheading(heading, size = 70)
    multi_lines(LogHelper.subheading(heading, size))
  end

  def section_heading(heading, size = 70)
    info(LogHelper.section_heading(heading, size))
  end

  def block(messages, include_line: true, title: nil)
    Thread.current[:log_formatter_suppress_severity] = true
    multi_lines(LogHelper.block(messages, include_line: include_line, title: title))
    Thread.current[:log_formatter_suppress_severity] = false
  end

  def json(data)
    info(JSON.pretty_generate(data))
  end

  private

  def multi_lines(lines)
    lines.each { |line| info(line) }
  end
end

Log = LogUtil.new(LogUtil.default_logger)
L = Log
