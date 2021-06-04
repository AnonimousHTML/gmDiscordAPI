
<h1 align="center">Ping</h1>

```lua
local discordClient = discordlib.client(token)
local channelID = "0"
local guildID = "0"

discordClient.on("GuildCreate","init",function(guild)
    if guild.id != guildID then return end
    local channel = guild.channels[channelID]
    if channel == nil then return end

    channel.send(discordlib.message().setText("ping").addComponents(discordlib.component().addButton("pong", discordlib.style.Success, "pong!","🏓", false)))
end)

discordClient.on("ButtonInteraction","response",function(interaction)
    if interaction.data.custom_id == "pong"
    then
        interaction.response(discordlib.response.ChannelMessageWithSource, discordlib.message().setText("ping").addComponents(discordlib.component().addButton("pong", discordlib.style.Success, "pong!","🏓", false)), function(...) discordlib.printTable({...}) end)
    end
end)

```

<h1 align="center"></h1>


<h1 align="center">Simple Chat Relay</h1>

```lua
if SERVER
then
    if discordClient then discordClient.destroy() discordClient = nil end
    discordClient = discordlib.client(token)
    discordClient.login()
    
    util.AddNetworkString("chatPrint")

    -- This is a bad implementation of chatprint it is written just for example
    local function chatPrint(...)
        net.Start("chatPrint")
            net.WriteTable({...})
        net.Broadcast()
    end

    local guildID = "679582744648351760"
    local relayChannelID = "679582744648351766"

    discordClient.on("GuildCreate", "init", function(guild)
        if guild.id != guildID then return end

        discordClient.on("MessageCreate","chatRelay",function(message)
            if !(message.guild and message.guild.id == guildID and message.channel.id == relayChannelID) then return end
            chatPrint("[DISCORD] " , message.author.getColor(), message.author.nick or message.author.user.username, "\n", color_white, message.content, message.attachments[1] and "\n" .. message.attachments[1].proxy_url)
        end)

        hook.Add("PlayerSay", "chatRelay", function(ply,text)
            discordClient.cache.guilds[guildID].channels[relayChannelID].send(discordlib.escapeMarkdown(ply:GetName() .. ": " .. text))
        end)

        gameevent.Listen("player_disconnect")
        hook.Add("player_disconnect", "chatRelay", function(data)
            discordClient.cache.guilds[guildID].channels[relayChannelID].send(discordlib.message().addEmbed(discordlib.messageEmbed()
                .setTitle("Player " .. data.name .. " disconnected")
                .addField("Reason", data.reason)
                .setColor(Color(255,50,50))
            ))
        end)

        gameevent.Listen("player_connect")
        hook.Add("player_connect", "chatRelay", function(data)
            discordClient.cache.guilds[guildID].channels[relayChannelID].send(discordlib.message().addEmbed(discordlib.messageEmbed()
                .setTitle("Player " .. data.name .. " is connecting to the server")
                .setColor(Color(50,255,50))
            ))
        end)

    end)
else
    net.Receive("chatPrint", function()
        chat.AddText(unpack(net.ReadTable()))
    end)
end
```

<h1 align="center"></h1>