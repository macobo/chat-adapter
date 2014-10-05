require 'sinatra'
require 'rest-client'
require_relative './helpers/slack_web_server'

module ChatAdapter
  # Slack adapter
  #
  # Relies on 
  # {https://slack.com/services/new/outgoing-webhook slack outgoing webhooks}
  # to respond to queries in channels and uses
  # {https://api.slack.com/methods/chat.postMessage slack api} to send private
  # messages.
  class Slack < Base
    OPTION_DEFAULTS = {
      nick: 'chatbot',
      channels: nil,
      icon_emoji: ':ghost:',
    }

    # Options passed to the instance, merged with defaults
    attr_reader :options
    # Sinatra server, see {ChatAdapter::Helpers::SlackWebServer}
    attr_reader :server

    # Create a new slack adapter
    #
    # @param [Hash] slack_options
    # @option slack_options [String] :nick (chatbot)
    # @option slack_options [Array<String>] :channels (nil) Channels to converse
    #     in. If nil, bot will respond to queries in all.
    # @option slack_options [String optional] :webhook_token Token given after
    #     creating {https://slack.com/services/new/outgoing-webhook an outgoing webhook}
    #     used to verify if the webhook came from the correct source.
    # @option slack_options [String optional] :api_token Token from 
    #     {https://api.slack.com/#auth slack api}, needed to send private
    #     messages.
    # @option slack_options [String] :icon_emoji (:ghost:) Emoji used as bot image.
    def initialize(slack_options)
      @options = OPTION_DEFAULTS.merge(slack_options)
      @server = ChatAdapter::Helpers::SlackWebServer

      @server.set :adapter, self
    end

    # Send a private message to an user
    def direct_message(user, message)
      unless options[:api_token]
        raise "No api_token given to bot, cannot send a direct message."
      end

      data = {
        username: options[:nick],
        icon_emoji: options[:icon_emoji],
        text: message,
        channel: user,
        token: options[:api_token]
      }
      PagerBot.log.info(data.inspect)

      resp = RestClient.post "https://slack.com/api/chat.postMessage", data
      PagerBot.log.info resp
    end

    # Grabs information about the message from the message object.
    #
    # @return [Hash] event_data Information about this message. :extra contains
    #     the original Sinatra request.
    # @see ChatAdapter::Base#process_message
    def event_data(request)
      {
        adapter: :slack,
        token: request[:token],
        user: request[:user_name],
        channel: request[:channel_name],
        extra: request
      }
    end

    # Verifies the webhook by checking if the token in request matches the one
    # given on creation (if one was given).
    def verify(event)
      options[:webhook_token].nil? || event[:token] == options[:webhook_token]
    end

    # Wrap the answer into a correct json object
    def post_process(answer)
      JSON.generate({
        username: options[:nick],
        icon_emoji: options[:icon_emoji],
        text: answer
      })
    end

    def start!
      @server.run!
    end

    def stop!
      @server.quit!
    end
  end
end
