require 'json'
require 'sinatra/base'

module ChatAdapter
  module Helpers
    # Web server for receiving web hooks from slack.
    # @see ChatAdapter::Slack
    class SlackWebServer < Sinatra::Base
      # @param slack_adapter [ChatAdapter::Slack]
      # @param webhook_url [String] url to POST to trigger webhook
      def initialize(slack_adapter, webhook_url)
        super
        @slack_adapter = slack_adapter
        @webhook_url = webhook_url
      end

      post @webhook_url do
        event = @slack_adapter.event_data(request)
        message = request[:text]

        answer = @slack_adapter.process_message(message, event)
        answer || ""
      end
    end
  end
end