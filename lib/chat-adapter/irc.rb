require 'cinch'

module ChatAdapter
  # Irc adapter
  #
  # Uses {https://github.com/cinchrb/cinch Cinch library} to handle
  # communicating with IRC.
  #
  # @example
  #   # Very silly example that responds to each message in channel.
  #   require 'chat-adapter'
  #   bot = ChatAdapter::IRC.new({
  #     server: 'irc.freenode.org',
  #     nick: 'shalalalabot',
  #     channels: ['#general']
  #   })
  #   
  #   bot.on_message { |message, event| "shalalalala" }
  #   bot.start
  class IRC < Base
    DEFAULT_CINCH_OPTIONS = {
      nick: 'chatbot',
      channels: [],
      password: nil,
      use_ssl: false
    }

    attr_reader :bot, :options
    # Create a new IRC adapter.
    #
    # @param [Hash] irc_options Options to pass to Cinch. Most params are
    #     described at {http://www.rubydoc.info/github/cinchrb/cinch/Cinch/Configuration/Bot Cinch::Configuration::Bot}.
    # @option irc_options [Boolean] :use_ssl
    def initialize(irc_options)
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

    # Grabs information about the message from the message object.
    #
    # @return [Hash] event_data Information about this message. :extra contains
    #     {http://www.rubydoc.info/github/cinchrb/cinch/Cinch/Message Cinch::Message}.
    # @see ChatAdapter::Base#process_message
    def event_data(m)
      {
        adapter: :irc,
        user: m.user.nick,
        channel: m.channel.name,
        extra: m
      }
    end

    # Avoid having empty lines, since IRC ignores those by default.
    def post_process(answer)
      answer.gsub(/^$/, " ")
    end

    def start!
      @bot.start
    end

    def stop!
      @bot.quit
    end
  end
end
