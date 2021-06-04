function discordlib.structures.message(client, message)

    if message.guild_id
    then
        local guild = client.cache.guilds[message.guild_id]
        message.channel = guild.channels[message.channel_id]
        message.guild = guild
        message.guild_id = nil
        if message.author
        then
            message.author = guild.members[message.author.id]
            message.member = nil
        end
    else
        message.channel = client.cache.private_channels[message.channel_id]
        message.author = discordlib.structures.user(client, message.author)
    end
    message.channel_id = nil

    if message.referenced_message
    then
        message.referenced_message.guild_id = message.message_reference.guild_id
        message.referenced_message.channel_id = message.message_reference.channel_id
        message.referenced_message = discordlib.structures.message(client, message.referenced_message)
        message.message_reference = nil
    end

    return message
end