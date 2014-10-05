require 'logger'

module ChatAdapter
  # logging function, included in most of the classes.
  def self.log
    return @logger unless @logger.nil?
    @logger = Logger.new STDERR
    @logger.level = Logger::DEBUG
    @logger.formatter = proc { |severity, datetime, progname, msg|
      "#{severity} #{caller[4]}: #{msg}\n"
    }
    @logger
  end
end
