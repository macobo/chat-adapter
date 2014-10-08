ENV['RACK_ENV'] = 'test'

require 'rack/test'
require_relative('../../_lib')

class Base < Critic::Test
  include Rack::Test::Methods

  def slack_bot(config={}, &blk)
    config['channels'] ||= ["#bot-testing"]
    @bot = ChatAdapter::Slack.new(config)

    @bot.on_message do |m, e|
      blk.call(m, e)
    end
    @bot
  end

  def answer
    return "" if last_response.body.empty?
    begin
      result = JSON.parse(last_response.body)
      result['text']
    rescue Exception => e
      last_response.body[0, 1000]
    end
  end

  def post_query(query={})
    post '/', query
  end

  def app
    @bot.server
  end

  describe 'Slack bot' do
    it 'should pass through simple requests' do
      slack_bot do |msg, event|
        next unless msg.start_with? "hello"
        "#{msg.capitalize}, #{event[:user]}"
      end
      post_query(text: "hi", user_name: "karl")
      assert_equal("", answer)

      post_query(text: "hello", user_name: "karl")
      assert_equal("Hello, karl", answer)
    end

    describe 'token verification' do
      before do
        slack_bot(webhook_token: 'abc') do |msg, event|
          msg
        end
      end

      it 'should return answer to query when correct token is passed by webhook' do
        post_query(text: 'testing', token: 'abc')
        assert_equal('testing', answer)
      end

      it 'should not return anything when wrong token is passed' do
        ChatAdapter.log.level = Logger::ERROR
        post_query(text: 'testing2', token: 'wrong')
        assert_equal('', answer)
      end
    end
  end
end
