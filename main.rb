# frozen_string_literal: true

# main view of the bot
require_relative 'Commands/commands'
require 'discordrb'
require 'configatron'
require_relative 'config'
#hello test
bot = Discordrb::Commands::CommandBot.new token: configatron.token, prefix: '!'
bot.include! Commands
bot.run
