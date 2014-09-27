module ChatAdapter
  class Base
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

    def post_process(answer)
      answer
    end

    # Validate the message came from the correct sources.
    # Useful for adapters like slack, where webhooks may originate from sources
    # other than the actual chatroom itself.
    #
    # @return bool if the message should be processed. By default true
    def validate(event_data)
      true
    end

    # Function to call from within your adapter when a new message is received.
    # 
    # It first calls validate to make sure the message should actually be
    # processed, followed by calling the specified message_processor.
    def process_message(message, event_data={})
      unless message_processor
        raise "No message processor registered. Please call on_message on the adapter."
      end

      is_valid = validate(event_data)
      unless validate(event_data)
        log.warn("Not valid request ignored: event_data=#{event_data}, message=#{message.inspect}")
        return nil
      end

      answer = message_processor.call(message, event_data)
      post_process(answer)
    end

    private
    def log
      return ChatAdapter::log
    end
  end
end
