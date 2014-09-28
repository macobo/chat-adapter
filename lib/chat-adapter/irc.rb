require 'cinch'

module ChatAdapter
  class IRC < Base
    DEFAULT_CINCH_OPTIONS = {
      nick: 'chatbot',
      channels: [],
      password: nil,
      use_ssl: false
    }

    attr_reader :bot, :options
    def initialize(irc_options = {})
      @options = DEFAULT_CINCH_OPTIONS.merge(irc_options)
      ChatAdapter.log.info(@options)

      @bot = Cinch::Bot.new

      @bot.config.ssl.use = @options.delete(:use_ssl)
      @bot.config.load(@options)
      @bot.config.channels = @options.fetch(:channels).map do |channel|
        channel.start_with?("#") ? channel : "#"+channel
      end

      # For some odd reason, cinch does everything in instance_eval within bot
      # save the reference to current adapter instance.
      # I thought we weren't writing javascript?
      adapter = self
      @bot.on :message do |m|
        answer = adapter.process_message(m.message, adapter.event_data(m))

        m.reply(answer) unless answer.nil?
      end
    end

    def event_data(m)
      {
        adapter: :irc,
        nick: m.user.nick,
        channel: m.channel.name,
        extra: m
      }
    end

    # Avoid having empty lines, since IRC ignores those by default.
    def post_process(answer)
      answer.gsub(/^$/, " ")
    end

    def start
      @bot.start
    end
  end
end
