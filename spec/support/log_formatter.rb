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
