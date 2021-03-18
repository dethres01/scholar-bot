# frozen_string_literal: true

# command container for the bot
require 'discordrb'
require 'configatron'
#require_relative '../config'

# Module for usual commands
module Commands
  extend Discordrb::Commands::CommandContainer
  command(:invite_url) do |event|
    event.bot.invite_url
  end
  command(:exit, help_available: false) do |event|
    break unless event.user.id == configatron.admin_id

    event.bot.send_message(event.channel.id, 'Bot is shutting down')
    exit
  end
  command(:roll) do |event, dice|
    if dice.match(/\d+d\d+/)
      # event.bot.send_message(event.channel.id,'Argumentos validos!')
      decode = dice.match(/(?<number_of_dice>\d+)d(?<dice_number>\d+)/)
      number_of_dice = decode[:number_of_dice].to_i
      dice_number = decode[:dice_number].to_i
      message = ''
      (1..number_of_dice).each do |_x|
        n = rand(1..dice_number)
        message += "#{n} "
      end
      event.bot.send_message(event.channel.id, ":game_die: #{message}")
    else
      event.bot.send_message(event.channel.id, 'Argumentos invalidos, recuerde usar un formato NdN')
    end
  end
end
