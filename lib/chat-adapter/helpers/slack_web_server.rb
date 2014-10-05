require 'json'
require 'sinatra/base'

module ChatAdapter
  # Helper classes for various adapters
  module Helpers
    # Web server for receiving web hooks from slack.
    # @see ChatAdapter::Slack
    class SlackWebServer < Sinatra::Base
      post '/' do
        event = settings.adapter.event_data(request)
        message = request[:text]
        ChatAdapter.log.info(message)

        answer = settings.adapter.process_message(message, event)
        answer || ""
      end

      # useful for heroku bots for pinging them automatically
      get '/ping' do
        ""
      end
    end
  end
end