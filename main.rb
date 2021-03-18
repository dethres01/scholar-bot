# frozen_string_literal: true

# main view of the bot
require_relative 'Commands/commands'
require_relative 'Commands/notes_commands'
require 'discordrb'
require 'configatron'
# require_relative 'config'
# hello test
bot = Discordrb::Commands::CommandBot.new token: ENV['configatron.token'], prefix: 'rin '
bot.include! Commands
bot.include! NotesCommands
bot.run
