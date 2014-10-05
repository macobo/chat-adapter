require 'chat-adapter'

bot = ChatAdapter::Shell.new({
  nick: 'karlbottt',
  channels: ['#bot-testing'],
  webhook_token: 'abc'
})

bot.on_message do |message, event_data|
  if message == '!stop'
    bot.stop!
  end

  "msg=#{message.inspect}, ed=#{event_data}"
end

bot.start!
puts "Done!"
