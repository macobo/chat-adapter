require 'colorize'

module ChatAdapter
  # Slack adapter
  #
  # Adapter for easily testing out your bot via shell.
  class Shell < Base
    OPTION_DEFAULTS = {
      nick: 'chatbot',
      channels: nil,
      start_state: {
        username: 'user',
        channel: '#channel'
      }
    }

    attr_reader :options

    # Create a new slack adapter
    #
    # @param [Hash] options
    # @option options [String] :nick (chatbot)
    # @option options [Array<String>] :channels (nil) Channels to converse
    #     in. If nil, bot will respond to queries in all.
    # @option 
    def initialize(options)
      @options = OPTION_DEFAULTS.merge(options)
      @state = {
        user: "user",
        channel: "#channel"
      }
    end

    # Bot sends a direct message 
    def direct_message(user, message)
      print "(DM to #{user}) #{options[:nick]}: ".bold
      puts message
    end

    # Grabs information about the message from the message object.
    #
    # @see ChatAdapter::Base#process_message
    def event_data
      @state.merge(adapter: :shell)
    end

    def start!
      replace_logger
      puts help.green

      @done = false
      while !@done
        # ask for query
        print current_prompt.bold
        input = gets.chomp

        if input == '!help'
          puts help.green.bold
        elsif input.start_with? '!channel '
          @state[:channel] = input.split(' ', 2)[1]
          puts "Changed channel to #{@state[:channel]}".green
        elsif input.start_with? '!nick '
          @state[:nick] = input.split(' ', 2)[1]
          puts "Changed nick to #{@state[:nick]}".green
        elsif input == '!exit'
          @done = true
        else
          answer = process_message(input, event_data)
          if answer
            print "#{options[:nick]}: ".bold
            puts answer
          else
            puts "#{options[:nick].bold} says nothing."
          end
        end
      end
    end

    def stop!
      @done = true
    end

    private
    def replace_logger
      return if @replaced
      @replaced = true
      base_formatter = ChatAdapter.log.formatter
      ChatAdapter.log.formatter = proc { |severity, datetime, progname, msg| 
        base_formatter.call(severity, datetime, progname, msg).yellow
      }
    end

    def current_prompt
      "[#{@state[:nick]} in #{@state[:channel]}]: "
    end

    def help
      <<-eos
Welcome! Use this adapter to test your bot by entering queries for it to respond to.

Note that log output for the bot is also shown. This can be toggled by entering #{"!logs".bold} as a query.

Other commands:
#{"!channel #newchannel".bold} - change current channel
#{"!nick newnick".bold} - change your username
#{"!help".bold} - show this help message
#{"!exit".bold} - exit this shell
      eos
    end
  end
end
