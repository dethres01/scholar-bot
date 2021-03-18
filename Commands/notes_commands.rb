require 'discordrb'
require 'configatron'
require 'rest-client'
require 'json'
require_relative '../config'

# Module for usual commands
module NotesCommands
  extend Discordrb::Commands::CommandContainer
  #health
  command(:health) do |event|
    response = RestClient.get("#{configatron.api_url}/health")

    payload = JSON.parse(response.to_str)
    event.bot.send_message(event.channel.id,"La api devolvio #{payload['api']}")
  end
  #notes_info
  command(:notes_info) do |event|
    event.channel.send_embed() do |embed|
      embed.title = "Notes commands"
      embed.colour = 0x18c795
      embed.description = "List of commands for note management prefix is ```rin ```"
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "#{event.server.member("#{configatron.client_id}").avatar_url}")
      embed.add_field(name: '```get_notes```', value: "devuelve la lista de notas del servidor")
      embed.add_field(name: '```create_note```', value: "Empieza el proceso para crear una nota y devuelve la nota creada")
      embed.add_field(name: '```show_note [id]```', value: "dado un ID, devuelve la nota si tiene la suficiente validación")
      embed.add_field(name: '```update_note [id]```', value: "dado un ID, devuelve la nota si tiene la suficiente validación y después comienza el proceso de edición")
      embed.add_field(name: '```delete_note [id]```', value: "dado un ID, devuelve la nota si tiene la suficiente validación y después comienza el proceso de eliminación si se da permiso")
    end
  end
  #get_notes
  command(:get_notes) do |event|
    response = RestClient.get("#{configatron.api_url}/notes?find=#{event.server.id}")
    payload = JSON.parse(response.to_str)
    event.channel.send_embed() do |embed|
      embed.title = "Notes for #{event.server.name}"
      embed.colour = 0x18c795
      embed.description="Probablemente podría esperar por algun input para ver si quieren ver una nota en específico"
      embed.timestamp = Time.at(1616079342)
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.server.name}", url: "https://discordapp.com", icon_url: "#{event.server.icon_url}")
      payload.each do |note|
        embed.add_field(name: "#{note['title']} [#{note['id']}]", value: "#{note['body'][0,50]}...")
      end
      #maybe implement a way to NOT show all of them properly
    end
  end
  #create_note
  command(:create_note) do |event|
    messages =['```json
    "dame el titulo"
    ```','```json
    "anota el contenido"
    ```']
    event.bot.send_message(event.channel.id,messages[0])

    titulo = event.user.await!
    event.bot.send_message(event.channel.id,messages[1])
    body = event.user.await!

    parameters ={"note"=> {"title"=> "#{titulo.message.content}", "body"=> "#{body.message.content}","discord_id"=> "#{event.user.id}","server_id"=> "#{event.server.id}"}}
    response = RestClient.post "#{configatron.api_url}/notes", parameters
    payload = JSON.parse(response.to_str)
    return_of_post = RestClient.get "#{configatron.api_url}/notes/#{payload['id']}?auth=#{event.server.id}"
    payload_of_post = JSON.parse(return_of_post.to_str)
    event.channel.send_embed() do |embed|
      embed.title = "#{payload_of_post['title']}"
      embed.colour = 0x6abf15
      embed.description="#{payload_of_post['body']}"
      embed.add_field(name: "note id: " ,value: "#{payload_of_post['id']}")
      embed.timestamp = Time.at(1616079342)
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.name}", url: "https://discordapp.com", icon_url: "#{event.user.avatar_url}")
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "#{event.server.icon_url}")
    end
  end
  command(:show_note) do |event,id|
    #event.bot.send_message(event.channel.id,id)
    response = RestClient.get "#{configatron.api_url}/notes/#{id}?auth=#{event.server.id}"
    payload = JSON.parse(response.to_str)

    event.channel.send_embed() do |embed|
      embed.title = "#{payload['title']}"
      embed.colour = 0x6abf15
      embed.description="#{payload['body']}"
      embed.add_field(name: "note id: " ,value: "#{payload['id']}")
      embed.timestamp = Time.at(1616079342)
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.server.member("#{payload['discord_id']}").name}", url: "https://discordapp.com", icon_url: "#{event.user.avatar_url}")
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "#{event.server.icon_url}")
    end
  end
  command(:update_note) do |event,id|
    response = RestClient.get "#{configatron.api_url}/notes/#{id}?auth=#{event.server.id}"
    payload = JSON.parse(response.to_str)

    event.channel.send_embed() do |embed|
      embed.title = "#{payload['title']}"
      embed.colour = 0x6abf15
      embed.description="#{payload['body']}"
      embed.add_field(name: "note id: " ,value: "#{payload['id']}")
      embed.timestamp = Time.at(1616079342)
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.server.member("#{payload['discord_id']}").name}", url: "https://discordapp.com", icon_url: "#{event.user.avatar_url}")
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "#{event.server.icon_url}")
    end
    messages =['```json
      "dame el titulo"
      ```','```json
      "anota el contenido"
      ```','```fix
      Elige que quieres modificar:
      1.Titulo
      2.Texto
      3.Titulo y texto
      ```']
      event.bot.send_message(event.channel.id,messages[2])
      #se deben agregar opciones de que agregar 
      #Un minimenú tal vez?
      opc = event.user.await!
      opc = opc.message.content
      case opc
      when "1"
        event.bot.send_message(event.channel.id,messages[0])
        titulo = event.user.await!
        parameters ={"note"=> {"title"=> "#{titulo.message.content}", "body"=> "#{payload['body']}","discord_id"=> "#{event.user.id}","server_id"=> "#{event.server.id}"}}
      when "2"
        event.bot.send_message(event.channel.id,messages[1])
        body = event.user.await!
        parameters ={"note"=> {"title"=> "#{payload['title']}", "body"=> "#{body.message.content}","discord_id"=> "#{event.user.id}","server_id"=> "#{event.server.id}"}}
      when "3"
        event.bot.send_message(event.channel.id,messages[0])

        titulo = event.user.await!
        event.bot.send_message(event.channel.id,messages[1])
        body = event.user.await!
    
        parameters ={"note"=> {"title"=> "#{titulo.message.content}", "body"=> "#{body.message.content}","discord_id"=> "#{event.user.id}","server_id"=> "#{event.server.id}"}}
      else
        event.bot.send_message(event.channel.id,"Invalido, matandome")
        break
      end
      response = RestClient.put "#{configatron.api_url}/notes/#{id}", parameters
      payload_1 = JSON.parse(response.to_str)
      return_of_post = RestClient.get "#{configatron.api_url}/notes/#{payload_1['id']}?auth=#{event.server.id}"
      payload_of_post = JSON.parse(return_of_post.to_str)
      event.channel.send_embed() do |embed|
        embed.title = "#{payload_of_post['title']}"
        embed.colour = 0x6abf15
        embed.description="#{payload_of_post['body']}"
        embed.add_field(name: "note id: " ,value: "#{payload_of_post['id']}")
        embed.timestamp = Time.at(1616079342)
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.name}", url: "https://discordapp.com", icon_url: "#{event.user.avatar_url}")
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "#{event.server.icon_url}")
      end
  end
  command(:delete_note) do |event,id|
    response = RestClient.get "#{configatron.api_url}/notes/#{id}?auth=#{event.server.id}"
    payload = JSON.parse(response.to_str)

    event.channel.send_embed() do |embed|
      embed.title = "#{payload['title']}"
      embed.colour = 0x6abf15
      embed.description="#{payload['body']}"
      embed.add_field(name: "note id: " ,value: "#{payload['id']}")
      embed.timestamp = Time.at(1616079342)
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.server.member("#{payload['discord_id']}").name}", url: "https://discordapp.com", icon_url: "#{event.user.avatar_url}")
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "#{event.server.icon_url}")
    end
    message = '```css
    [Are you sure?]
    [Y/N]
    ```'
    event.bot.send_message(event.channel.id,message)
    res = event.user.await!
    if res.message.content.upcase == "Y"
      response = RestClient.delete "#{configatron.api_url}/notes/#{id}?auth=#{event.user.id}"
      payload = JSON.parse(response.to_str)
      event.bot.send_message(event.channel.id, "Eliminado con exito!")
    else
      event.bot.send_message(event.channel.id,"Saliendo del comando")
    end
  end
end