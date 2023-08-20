# frozen_string_literal: true

require_relative 'log_usecases'

class LogUtil
  include LogUsecases

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
