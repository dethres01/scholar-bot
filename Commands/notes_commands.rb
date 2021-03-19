# frozen_string_literal: true

require 'discordrb'
require 'configatron'
require 'rest-client'
require 'json'
# require_relative '../config'

# Module for usual commands
module NotesCommands
  extend Discordrb::Commands::CommandContainer
  # health

  command(:health) do |event|
    response = RestClient.get("#{ENV['configatron.api_url']}/health")

    payload = JSON.parse(response.to_str)
    if payload['api'] == "OK"
      event.bot.send_message(event.channel.id, "La base de datos esta conectada!")
    end
  end
  # notes_info

  # get_notes
  command(:get_notes) do |event|
    response = RestClient.get("#{ENV['configatron.api_url']}/notes?find=#{event.server.id}")
    payload = JSON.parse(response.to_str)
    event.channel.send_embed do |embed|
      embed.title = "Notes for #{event.server.name}"
      embed.colour = 0x18c795
      embed.description = 'Probablemente podría esperar por algun input para ver si quieren ver una nota en específico'
      embed.timestamp = Time.now
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.server.name.to_s, url: 'https://discordapp.com',
                                                          icon_url: event.server.icon_url.to_s)
      payload.each do |note|
        embed.add_field(name: "#{note['title']} [#{note['id']}]", value: "#{note['body'][0, 50]}...")
      end
      # maybe implement a way to NOT show all of them properly
    end
  end
  # create_note
  command(:create_note) do |event|
    messages = ['```json
    "dame el titulo"
    ```', '```json
    "anota el contenido"
    ```']
    event.bot.send_message(event.channel.id, messages[0])

    titulo = event.user.await!
    event.bot.send_message(event.channel.id, messages[1])
    body = event.user.await!

    parameters = { 'note' => { 'title' => titulo.message.content.to_s, 'body' => body.message.content.to_s,
                               'discord_id' => event.user.id.to_s, 'server_id' => event.server.id.to_s } }
    response = RestClient.post "#{ENV['configatron.api_url']}/notes", parameters
    payload = JSON.parse(response.to_str)
    return_of_post = RestClient.get "#{ENV['configatron.api_url']}/notes/#{payload['id']}?auth=#{event.server.id}"
    payload_of_post = JSON.parse(return_of_post.to_str)
    event.channel.send_embed do |embed|
      embed.title = (payload_of_post['title']).to_s
      embed.colour = 0x6abf15
      embed.description = (payload_of_post['body']).to_s
      embed.add_field(name: 'note id: ', value: (payload_of_post['id']).to_s)
      embed.timestamp = Time.now
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.user.name.to_s, url: 'https://discordapp.com',
                                                          icon_url: event.user.avatar_url.to_s)
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url.to_s)
    end
  end
  command(:show_note) do |event, id|
    # event.bot.send_message(event.channel.id,id)
    response = RestClient.get "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.server.id}"
    payload = JSON.parse(response.to_str)

    event.channel.send_embed do |embed|
      embed.title = (payload['title']).to_s
      embed.colour = 0x6abf15
      embed.description = (payload['body']).to_s
      embed.add_field(name: 'note id: ', value: (payload['id']).to_s)
      embed.timestamp = Time.now
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(
        name: event.server.member((payload['discord_id']).to_s).name.to_s, url: 'https://discordapp.com', icon_url: event.user.avatar_url.to_s
      )
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url.to_s)
    end
  end
  command(:update_note) do |event, id|
    response = RestClient.get "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.server.id}"
    payload = JSON.parse(response.to_str)

    event.channel.send_embed do |embed|
      embed.title = (payload['title']).to_s
      embed.colour = 0x6abf15
      embed.description = (payload['body']).to_s
      embed.add_field(name: 'note id: ', value: (payload['id']).to_s)
      embed.timestamp = Time.now
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(
        name: event.server.member((payload['discord_id']).to_s).name.to_s, url: 'https://discordapp.com', icon_url: event.user.avatar_url.to_s
      )
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url.to_s)
    end
    messages = ['```json
      "dame el titulo"
      ```', '```json
      "anota el contenido"
      ```', '```fix
      Elige que quieres modificar:
      1.Titulo
      2.Texto
      3.Titulo y texto
      ```']
    event.bot.send_message(event.channel.id, messages[2])
    # se deben agregar opciones de que agregar
    # Un minimenú tal vez?
    opc = event.user.await!
    opc = opc.message.content
    case opc
    when '1'
      event.bot.send_message(event.channel.id, messages[0])
      titulo = event.user.await!
      package = parameters(titulo.message.content,payload['body'],event.user.id,event.server.id)
    when '2'
      event.bot.send_message(event.channel.id, messages[1])
      body = event.user.await!
      parameters = { 'note' => { 'title' => (payload['title']).to_s, 'body' => body.message.content.to_s,
                                 'discord_id' => event.user.id.to_s, 'server_id' => event.server.id.to_s } }
    when '3'
      event.bot.send_message(event.channel.id, messages[0])

      titulo = event.user.await!
      event.bot.send_message(event.channel.id, messages[1])
      body = event.user.await!

      parameters = { 'note' => { 'title' => titulo.message.content.to_s, 'body' => body.message.content.to_s,
                                 'discord_id' => event.user.id.to_s, 'server_id' => event.server.id.to_s } }
    else
      event.bot.send_message(event.channel.id, 'Invalido, matandome')
      break
    end
    response = RestClient.put "#{ENV['configatron.api_url']}/notes/#{id}", parameters
    payload_1 = JSON.parse(response.to_str)
    return_of_post = RestClient.get "#{ENV['configatron.api_url']}/notes/#{payload_1['id']}?auth=#{event.server.id}"
    payload_of_post = JSON.parse(return_of_post.to_str)
    event.channel.send_embed do |embed|
      embed.title = (payload_of_post['title']).to_s
      embed.colour = 0x6abf15
      embed.description = (payload_of_post['body']).to_s
      embed.add_field(name: 'note id: ', value: (payload_of_post['id']).to_s)
      embed.timestamp = Time.now
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: event.user.name.to_s, url: 'https://discordapp.com',
                                                          icon_url: event.user.avatar_url.to_s)
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url.to_s)
    end
  end
  command(:delete_note) do |event, id|
    response = RestClient.get "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.server.id}"
    payload = JSON.parse(response.to_str)

    event.channel.send_embed do |embed|
      embed.title = (payload['title']).to_s
      embed.colour = 0x6abf15
      embed.description = (payload['body']).to_s
      embed.add_field(name: 'note id: ', value: (payload['id']).to_s)
      embed.timestamp = Time.now
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(
        name: event.server.member((payload['discord_id']).to_s).name.to_s, url: 'https://discordapp.com', icon_url: event.user.avatar_url.to_s
      )
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url.to_s)
    end
    message = '```css
    [Are you sure?]
    [Y/N]
    ```'
    event.bot.send_message(event.channel.id, message)
    res = event.user.await!
    if res.message.content.upcase == 'Y'
      response = RestClient.delete "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.user.id}"
      payload = JSON.parse(response.to_str)
      event.bot.send_message(event.channel.id, 'Eliminado con exito!')
    else
      event.bot.send_message(event.channel.id, 'Saliendo del comando')
    end
  end
  private
  def self.parameters(title,body,discord_id,server_id)
    return {'note' => { 'title' => (title).to_s, 'body' => body.to_s,
      'discord_id' => discord_id.to_s, 'server_id' => server_id.to_s } }
  end
end
