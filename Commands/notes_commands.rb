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
    message = ">>> Informacion de notas \n
    !get_notes -> obtiene las notas del server"
  end
  #get_notes
  command(:get_notes) do |event|
    response = RestClient.get("#{configatron.api_url}/notes?find=#{event.server.id}")
    payload = JSON.parse(response.to_str)
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
    #event.bot.send_message(event.channel.id,"#{parameters}")
    response = RestClient.post "#{configatron.api_url}/notes", parameters
    payload = JSON.parse(response.to_str)
    return_of_post = RestClient.get "#{configatron.api_url}/notes/#{payload['id']}"

    payload_of_post = JSON.parse(return_of_post.to_str)
    #event.bot.send_message(event.channel.id,"#{payload_of_post}")
    event.channel.send_embed() do |embed|
      embed.title = "#{payload_of_post['title']}"
      embed.colour = 0x6abf15
      embed.description="#{payload_of_post['body']}"
      embed.timestamp = Time.at(1616079342)
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(name: "#{event.user.name}", url: "https://discordapp.com", icon_url: "#{event.user.avatar_url}")
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "#{event.server.icon_url}")

    end
    #  embed.title = "title ~~(did you know you can have markdown here too?)~~"
    #  embed.colour = 0x3020f2
    #  embed.url = "https://discordapp.com"
    #  embed.description = "this supports [named links](https://discordapp.com) on top of the previously shown subset of markdown. ```\nyes, even code blocks```"
    
    #
    #  embed.image = Discordrb::Webhooks::EmbedImage.new(url: "https://cdn.discordapp.com/embed/avatars/0.png")
    #  
    #  embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "footer text", icon_url: "https://cdn.discordapp.com/embed/avatars/0.png")
    #
    #  embed.add_field(name: "🤔", value: "some of these properties have certain limits...")
    #  embed.add_field(name: "😱", value: "try exceeding some of them!")
    #  embed.add_field(name: "🙄", value: "an informative error should show up, and this view will remain as-is until all issues are fixed")
    #  embed.add_field(name: "<:thonkang:219069250692841473>", value: "these last two", inline: true)
    #  embed.add_field(name: "<:thonkang:219069250692841473>", value: "are inline fields", inline: true)
    #end

  end
end