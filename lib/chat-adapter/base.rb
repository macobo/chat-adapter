module ChatAdapter
  # Base class that all adapters inherit from which takes care of some of the
  # internal plumbing
  class Base
    # @return [Proc] Function passed to #{on_message} as block, containing
    #    how logic about how the user wants to deal with message.
    attr_reader :message_processor

    def initialize
      raise "ChatAdapter::Base cannot be directly initiated. Create a subclass\
            instead!"
    end

    # Register a block to be called each time a new message is received from
    # chat.
    def on_message(&processor_block)
      raise "Message processor already registered" if @message_processor
      @message_processor = processor_block
    end

    # Send a direct message to a user
    # @abstract
    def direct_message(user, message)
      raise "Not implemented for #{self}"
    end

    # TODO: send_to_channel?

    # Starts the chatbot. Blocks until {#stop!} is called
    # @abstract
    def start!; end

    # Stops the chatbot, returning from the {#start!} call.
    # @abstract
    def stop!; end

    # Verify the message came from the correct sources.
    # Useful for adapters like slack, where webhooks may originate from sources
    # other than the actual chatroom itself.
    #
    # @return [Boolean] Should the message be processed? Defaults to true.
    def verify(event_data)
      true
    end

    # Function to call from within your adapter when a new message is received.
    # 
    # It first calls veriy to make sure the message should actually be
    # processed, followed by calling the specified message_processor.
    #
    # @param [String] message
    # @param [Hash] event_data
    # @option event_data [Symbol] :adapter Type of adapter e.g. :irc or :slack
    # @option event_data [String] :channel What channel the message occurred in
    # @option event_data [String] :user Nickname of the user who sent the message
    # @option event_data :extra Extra information passed by adapter.
    def process_message(message, event_data={})
      unless message_processor
        raise "No message processor registered. Please call on_message on the adapter."
      end

      is_valid = verify(event_data)
      unless verify(event_data)
        log.warn("Not valid request ignored: event_data=#{event_data}, message=#{message.inspect}")
        return nil
      end

      answer = message_processor.call(message, event_data)
      post_process(answer)
    end

    # Post-processes the answer to query. By default does nothing.
    # TODO: add hooks to provide post-processing.
    def post_process(answer)
      answer
    end

    private
    def log
      return ChatAdapter::log
    end
  end
end
