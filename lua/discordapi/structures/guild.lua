function discordlib.structures.guild(client, guild)
    local channels = {}
    local roles = {}
    for k,role in ipairs(guild.roles)
    do
        roles[role.id] = discordlib.structures.role(client, role)
    end
    guild.roles = roles

    for k,channel in ipairs(guild.channels)
    do
        channels[channel.id] = discordlib.structures.channel(client, channel, guild)
    end
    guild.channels = channels

    local members = {}
    for k,member in ipairs(guild.members)
    do
        members[member.user.id] =  discordlib.structures.member(client, member, guild)
    end
    guild.members = members

    local emojis = {}
    for k,emoji in ipairs(guild.emojis)
    do
        emojis[emoji.id] = discordlib.structures.emoji(client, emoji)
    end
    guild.emojis = emojis

    function guild.unban(userID = !err, callback)
        client.unbanMember(guild.id, userID, callback)
    end

    function guild.getBans(callback)
        client.getGuildBans(guild.id,callback)
    end

    function guild.getCommands(callback)
        client.getGuildCommands(guild.id, callback)
    end

    function guild.addCommand(command = !err, callback)
        client.createGuildCommand(command, guild.id, callback)
    end    

    function guild.editCommand(command = !err, commandID = !err, callback)
        client.editGuildCommand(command, guild.id, commandID, callback)
    end
    
    function guild.deleteCommand(commandID = !err, callback)
        client.deleteGuildCommand(guild.id, commandID, callback)
    end

    return guild
end