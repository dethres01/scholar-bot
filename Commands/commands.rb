# frozen_string_literal: true

# command container for the bot
require 'discordrb'
require 'configatron'
# require_relative '../config'

# Module for usual commands
module Commands
  extend Discordrb::Commands::CommandContainer
  command(:help) do |event|
    event.channel.send_embed do |embed|
      embed.title = 'General Commands'
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.member((ENV['configatron.client_id']).to_s).avatar_url.to_s)
      embed.colour = 0xe6460b
      embed.description = 'List of General Commands'
      embed.add_field(name: '```health```', value: 'Devuelve la condicion general de la API/base de datos')
      embed.add_field(name: '```help```', value: 'devuelve la lista de comandos disponibles')
      embed.add_field(name: '```roll [NdN]```', value: 'rueda dados, que quieres que diga')
    end
    event.channel.send_embed do |embed|
      embed.title = 'Notes commands'
      embed.colour = 0x18c795
      embed.description = 'List of commands for note management prefix is ```rin ```'
      embed.add_field(name: '```get_notes```', value: 'devuelve la lista de notas del servidor')
      embed.add_field(name: '```create_note```',
                      value: 'Empieza el proceso para crear una nota y devuelve la nota creada')
      embed.add_field(name: '```show_note [id]```',
                      value: 'dado un ID, devuelve la nota si tiene la suficiente validación')
      embed.add_field(name: '```update_note [id]```',
                      value: 'dado un ID, devuelve la nota si tiene la suficiente validación y después comienza el proceso de edición')
      embed.add_field(name: '```delete_note [id]```',
                      value: 'dado un ID, devuelve la nota si tiene la suficiente validación y después comienza el proceso de eliminación si se da permiso')
    end
  end
  command(:invite_url) do |event|
    event.bot.invite_url
  end

  command(:exit, help_available: false) do |event|
    break unless event.user.id == ENV['configatron.admin_id']

    event.bot.send_message(event.channel.id, 'Bot is shutting down')
    exit
  end

  command(:roll) do |event, dice|
    if dice.match(/\d+d\d+/)
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
