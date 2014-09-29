require 'json'
require 'sinatra/base'

module ChatAdapter
  module Helpers
    # Web server for receiving web hooks from slack.
    # @see ChatAdapter::Slack
    class SlackWebServer < Sinatra::Base
      post '/slack' do
        event = settings.adapter.event_data(request)
        message = request[:text]
        ChatAdapter.log.info(message)

        answer = settings.adapter.process_message(message, event)
        answer || ""
      end

      # useful for heroku bots for pinging them automatically
      get '/slack' do
        ""
      end
    end
  end
end