# frozen_string_literal: true

# command container for the bot
require 'discordrb'
require 'configatron'
require_relative '../config'

# Module for usual commands
module Commands
  extend Discordrb::Commands::CommandContainer
  command(:exit, help_available: false) do |event|
    break unless event.user.id == configatron.admin_id

    event.bot.send_message(event.channel.id, 'Bot is shutting down')
    exit
  end
end
