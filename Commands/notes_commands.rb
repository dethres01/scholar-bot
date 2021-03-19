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
    begin
      response = RestClient.get("#{ENV['configatron.api_url']}/health")
    rescue StandardError
      event.bot.send_message(event.channel.id, 'Se ha detectado un problema!')
    else
      event.bot.send_message(event.channel.id, 'La base de datos esta conectada!')
    end
  end
  # notes_info

  # get_notes
  command(:get_notes) do |event|
    response = RestClient.get("#{ENV['configatron.api_url']}/notes?find=#{event.server.id}")
    payload = parse(response)
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
    test_delete =event.bot.send_message(event.channel.id, messages[0])
    event.bot.send_message(event.channel.id,"#{test_delete}")
    titulo = event.user.await!
    title = titulo.message.content
    titulo.message.delete
    
    event.bot.send_temporary_message(event.channel.id, messages[1],60)
    body = event.user.await!
    content = body.message.content
    body.message.delete
    package = parameters(title, content, event.user.id, event.server.id)
    
    
    response = RestClient.post "#{ENV['configatron.api_url']}/notes", package
    # se ejecuto post
    payload = parse(response)
    response = RestClient.get "#{ENV['configatron.api_url']}/notes/#{payload['id']}?auth=#{event.server.id}"
    payload = parse(response)

    normal_embed(event, payload)
  end
  command(:show_note) do |event, id|
    response = RestClient.get "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.server.id}"
    payload = parse(response)

    normal_embed(event, payload)
  end
  command(:update_note) do |event, id|
    response = RestClient.get "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.server.id}"
    payload = parse(response)

    normal_embed(event, payload)

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
    opc = event.user.await!
    opc = opc.message.content
    case opc
    when '1'
      event.bot.send_message(event.channel.id, messages[0])
      titulo = event.user.await!
      package = parameters(titulo.message.content, payload['body'], event.user.id, event.server.id)
    when '2'
      event.bot.send_message(event.channel.id, messages[1])
      body = event.user.await!
      package = parameters(payload['title'], body.message.content, event.user.id, event.server.id)
    when '3'
      event.bot.send_message(event.channel.id, messages[0])

      titulo = event.user.await!
      event.bot.send_message(event.channel.id, messages[1])
      body = event.user.await!

      parameters = parameters(titulo.message.content, body.message.content, event.user.id, event.server.id)
    else
      event.bot.send_message(event.channel.id, 'Opcion Invalida, Lo siento!')
      break
    end
    begin
      RestClient.put "#{ENV['configatron.api_url']}/notes/#{id}", package
    rescue StandardError
      event.bot.send_message(event.channel.id, 'Oh, parece que hubo un problema, contacta al owner')
      break
    else
    end
    response = RestClient.get "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.server.id}"
    payload = parse(response)

    normal_embed(event, payload)
  end
  command(:delete_note) do |event, id|
    response = RestClient.get "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.server.id}"
    payload = parse(response)

    normal_embed(event, payload)
    message = '```css
    [Are you sure?]
    [Y/N]
    ```'
    event.bot.send_message(event.channel.id, message)
    res = event.user.await!

    if res.message.content.upcase == 'Y'
      begin
        response = RestClient.delete "#{ENV['configatron.api_url']}/notes/#{id}?auth=#{event.user.id}"
      rescue StandardError
        event.bot.send_message(event.channel.id,
                               'Hubo un problema eliminando el post, esto puede ser por varias razones asi que contacta al owner')
      else
        payload = parse(response)
        event.bot.send_message(event.channel.id, 'Eliminado con exito!')
      end
    else
      event.bot.send_message(event.channel.id, 'Input invalido o Negación, Saliendo del comando')
    end
  end

  # functions
  def self.parse(response)
    JSON.parse(response.to_str)
  end

  def self.normal_embed(event, payload)
    event.channel.send_embed do |embed|
      embed.title = (payload['title']).to_s
      embed.colour = 0x6abf15
      embed.description = (payload['body']).to_s
      embed.add_field(name: 'note id: ', value: (payload['id']).to_s)
      embed.timestamp = Time.now
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(
        name: event.server.member((payload['discord_id']).to_s).name.to_s, url: 'https://discordapp.com', icon_url: event.server.member((payload['discord_id']).to_s).avatar_url
      )
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.server.icon_url.to_s)
    end
  end

  def self.parameters(title, body, discord_id, server_id)
    { 'note' => { 'title' => title.to_s, 'body' => body.to_s,
                  'discord_id' => discord_id.to_s, 'server_id' => server_id.to_s } }
  end
end
