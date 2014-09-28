require 'chat-adapter'

bot = ChatAdapter::IRC.new({
  nick: 'karlbottt',
  server: 'irc.freenode.org',
  channels: ['#bot-testing']
})

bot.on_message do |message, event_data|
  "#{message}, ed=#{event_data}"
end

bot.start