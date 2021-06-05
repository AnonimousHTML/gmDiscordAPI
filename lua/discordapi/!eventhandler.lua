local EVENT_HANDLERS = {}

function discordlib.handleEvent(client, payload)
    local fn = EVENT_HANDLERS[payload.t]
    if fn
    then
        fn(client, payload.d)
    end
#ifdef DISCORD_DEBUG
    print(payload.t)
#endif
end

function EVENT_HANDLERS.READY(client, payload)
    if client.ready then return end
    client.ready = true
    client.user = discordlib.structures.user(client, payload.user)
    client.sessionID = payload.session_id
    client.emitEvent("Ready", payload)
end

////////// GUILD

function EVENT_HANDLERS.GUILD_CREATE(client, payload)
    client.cache.guilds[payload.id] = discordlib.structures.guild(client, payload)
    client.emitEvent("GuildCreate", client.cache.guilds[payload.id])
end

////////// MEMBER

function EVENT_HANDLERS.GUILD_MEMBER_ADD(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    payload.guild_id = nil
    guild.members[payload.user.id] = discordlib.structures.member(client, payload, guild)
    client.emitEvent("GuildMemberAdd",guild, guild.members[payload.user.id])
end

function EVENT_HANDLERS.GUILD_MEMBER_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    payload.guild_id = nil
    local oldMemberData = guild.members[payload.user.id]
    guild.members[payload.user.id] = discordlib.structures.member(client, payload, guild)
    client.emitEvent("GuildMemberUpdate", guild, guild.members[payload.user.id], oldMemberData)
end


function EVENT_HANDLERS.GUILD_MEMBER_REMOVE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    client.emitEvent("GuildMemberRemove", guild, guild.members[payload.user.id])
    payload.guild_id = nil
    guild.members[payload.user.id] = nil
end

////////// CHANNEL

function EVENT_HANDLERS.CHANNEL_CREATE(client, payload)
    -- dm channel
    if payload.type == 1
    then
        client.cache.private_channels[payload.id] = discordlib.structures.channel(client, payload)
        return
    end

    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        payload.guild_id = nil
        payload.guild_hashes = nil
        guild.channels[payload.id] = discordlib.structures.channel(client, payload, guild)
        client.emitEvent("ChannelCreate", guild.channels[payload.id])
    end

end

function EVENT_HANDLERS.CHANNEL_UPDATE(client, payload)
    -- dm channel
    if payload.type == 1
    then
        client.cache.private_channels[payload.id] = discordlib.structures.channel(client, payload)
        return
    end

    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        payload.guild_id = nil
        payload.guild_hashes = nil
        local oldChannelData = guild.channels[payload.id]
        guild.channels[payload.id] = discordlib.structures.channel(client, payload, guild)
        client.emitEvent("ChannelUpdate", guild.channels[payload.id], oldChannelData)
    end

end

function EVENT_HANDLERS.CHANNEL_DELETE(client, payload)
    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        client.emitEvent("ChannelDelete", guild.channels[payload.id])
        guild.channels[payload.id] = nil
    end
end

////////// MESSAGE

function EVENT_HANDLERS.MESSAGE_CREATE(client, payload)
    client.emitEvent("MessageCreate", discordlib.structures.message(client, payload))
end

function EVENT_HANDLERS.MESSAGE_UPDATE(client, payload)
    client.emitEvent("MessageUpdate", discordlib.structures.message(client, payload))
end

function EVENT_HANDLERS.MESSAGE_DELETE(client, payload)
    client.emitEvent("MessageDelete", payload)
end

////////// ROLE

function EVENT_HANDLERS.GUILD_ROLE_CREATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    guild.roles[payload.role.id] = discordlib.structures.role(client, payload.role)
    client.emitEvent("GuildRoleCreate",guild,  guild.roles[payload.role.id])
end

function EVENT_HANDLERS.GUILD_ROLE_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    local oldRoleData = guild.roles[payload.role.id]
    guild.roles[payload.role.id] = discordlib.structures.role(client, payload.role)
    client.emitEvent("GuildRoleUpdate",guild,  guild.roles[payload.role.id], oldRoleData)
end

function EVENT_HANDLERS.GUILD_ROLE_DELETE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    client.emitEvent("GuildRoleDelete",guild, guild.roles[payload.role_id])
    guild.roles[payload.role_id] = nil
end

////////// EMOJI

function EVENT_HANDLERS.GUILD_EMOJIS_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    
    local emojis = {}
    for k,emoji in ipairs(payload.emojis)
    do
        emojis[emoji.id] = discordlib.structures.emoji(client, emoji)
    end

    guild.emojis = emojis

    client.emitEvent("GuildEmojisUpdate", guild)
end

////////// REACTIONS

function EVENT_HANDLERS.MESSAGE_REACTION_ADD(client, payload)
    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end

        client.emitEvent("MessageReactionAdd", payload.emoji, guild.members[payload.member.user_id], {message_id = payload.message_id, guild_id = payload.guild_id, channel_id = payload.channel_id})
    else
        client.emitEvent("MessageReactionAdd", payload.emoji, client.cache.users[payload.user_id] or payload.user_id, {message_id = payload.message_id, guild_id = payload.guild_id, channel_id = payload.channel_id})
    end
end

function EVENT_HANDLERS.MESSAGE_REACTION_REMOVE(client, payload)
    if payload.guild_id
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        client.emitEvent("MessageReactionRemove", payload.emoji, guild.members[payload.user_id], {message_id = payload.message_id, guild_id = payload.guild_id, channel_id = payload.channel_id})
    else
        client.emitEvent("MessageReactionRemove", payload.emoji, client.cache.users[payload.user_id] or payload.user_id, {message_id = payload.message_id, guild_id = payload.guild_id, channel_id = payload.channel_id})
    end
end


////////// Webhooks

function EVENT_HANDLERS.WEBHOOKS_UPDATE(client, payload)
    local guild = client.cache.guilds[payload.guild_id]
    if guild == nil then return error("${__FUNCTION__} uncached guild") end
    client.emitEvent("WebhooksUpdate", guild, guild.channels[payload.channel_id])
end


////////// Interaction

function EVENT_HANDLERS.INTERACTION_CREATE(client, payload)
    if payload.member
    then
        local guild = client.cache.guilds[payload.guild_id]
        if guild == nil then return error("${__FUNCTION__} uncached guild") end
        payload.guild = guild
        payload.guild_id = nil
        payload.member = guild.members[payload.member.user.id]
    end

    payload = discordlib.structures.interaction(client, payload)
    if payload.type == 3
    then
        payload.message = discordlib.structures.message(client, payload.message)
        client.emitEvent("ButtonInteraction", payload)
    elseif payload.type == 2
    then
        client.emitEvent("SlashCommandInteraction", payload)
    end
end