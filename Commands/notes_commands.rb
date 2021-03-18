require 'discordrb'
require 'configatron'
require 'rest-client'
require 'json'
require_relative '../config'

# Module for usual commands
module NotesCommands
  extend Discordrb::Commands::CommandContainer
  command(:health) do |event|
    response = RestClient.get("#{configatron.api_url}/health")

    payload = JSON.parse(response.to_str)
    event.bot.send_message(event.channel.id,"La api devolvio #{payload['api']}")
  end
  command(:notes_info) do |event|
    message = ">>> Informacion de notas \n
    !get_notes -> obtiene las notas del server"
  end
  command(:get_notes) do |event|
    response = RestClient.get("#{configatron.api_url}/notes?find=#{event.server.id}")
    payload = JSON.parse(response.to_str)
  end
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
    event.bot.send_message(event.channel.id,"#{parameters}")
    response = RestClient.post "#{configatron.api_url}/notes", parameters



  end
end