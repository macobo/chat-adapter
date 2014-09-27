require 'logger'

module ChatAdapter
  def self.log
    return @logger unless @logger.nil?
    @logger = Logger.new STDERR
    @logger.level = Logger::INFO
    @logger.formatter = proc { |severity, datetime, progname, msg|
      "#{severity} #{caller[4]}: #{msg}\n"
    }
    @logger
  end
end
