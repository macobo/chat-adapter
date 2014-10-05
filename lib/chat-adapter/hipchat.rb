require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'

module ChatAdapter
  class HipChat < Base
    OPTION_DEFAULTS = {
      nick: 'chatbot',
      channels: []
    }

    # Options passed to the instance, merged with defaults
    attr_reader :options

    def initialize(hc_options)
      @options = OPTION_DEFAULTS.merge(hc_options)

      if options[:jabber_id].nil?
        raise "Must pass option :jabber_id to #{self.class}.initialize"
      end
      @client = Jabber::Client.new(options[:jabber_id])
    end

    # Start the connection to the jabber client.
    def start!
      connect
      create_listeners(options[:channels])

      log.info "Setting presence to AVAILABLE."
      @client.send(Jabber::Presence.new.set_type(:available))
      @done = false
      until @done
        sleep 0.5
      end
      @client.close
    end

    # Stops serving the bot.
    def stop!
      @done = false
    end

    private
    def connect
      attempt = 0
      while true
        attempt += 1

        begin
          @client.connect
          break
        rescue SocketError => e
          log.error "Network Error(#{attempt}): #{e}"
          log.error "Sleeping #{"%.1f"%rest}s"
          sleep(5 * (1 + Math.log(attempt)))
        end
      end

      log.info "Connected to hipchat."
      log.debug "#{@client}"

      @client.auth(options[:password]) unless options[:password].nil?
    end

    def create_listeners(channels)
      @listeners = {}

      channels.each do |channel|
        listener = Jabber::MUC::SimpleMUCClient.new(@client)

        log.debug("Joining #{channel}.")
        listener.join "#{channel}/#{options[:nick]}"
        log.info("Joined #{channel} - topic is #{listener.subject}")

        register_listener(listener, channel)

        @listeners[channel] = listener
      end 
    end

    def register_listener(listener, channel)
      listener.on_message do |time, user, message|
        message.encode!("UTF-8")
        user.encode!("UTF-8")

        return if user == options[:nick]

        event = {
          adapter: :hipchat,
          nick: user,
          channel: channel,
        }

        answer = process_message(message, event)
        unless answer.nil?
          listener.send Jabber::Message.new(listener.room, answer)
        end
      end
    end
  end
end
