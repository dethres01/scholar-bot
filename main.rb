#main view of the bot
require_relative 'Commands/commands.rb'
require 'discordrb'
require 'configatron'
require_relative 'config.rb'

bot = Discordrb::Commands::CommandBot.new token: configatron.token, prefix: '!'
bot.include! Commands
bot.run
