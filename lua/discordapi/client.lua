for k,file in ipairs(file.Find("discordapi/structures/*.lua", "LUA"))
do
    gproclib.include("discordapi/structures/" .. file)
end
for k,file in ipairs(file.Find("discordapi/constructors/*.lua", "LUA"))
do
    gproclib.include("discordapi/constructors/" .. file)
end

local max_table_size = 9007199254740991 -- 2^53-1
local function queue()
    local metatable = {}

    metatable.push = function(self, value)
        if value == nil then return end
        if self.count >= max_table_size then error("queue overflow") end

        self.last = (self.last + 1) % max_table_size
        self.count = self.count + 1
        self[self.last] = value
    end

    metatable.pop = function(self)
        if self.count == 0 then return end

        self.first = (self.first + 1) % max_table_size
        self.count = self.count - 1

        local out = self[self.first]
        self[self.first] = nil

        return out
    end

    return setmetatable({
        first = 0,
        last = 0,
        count = 0,
    }, {__index = metatable})
end

local pairs = pairs
local ipairs = ipairs
local JSONToTable = util.JSONToTable
local _TableToJSON = util.TableToJSON
local _r = function(int) return int end
local function TableToJSON(table = !ret "[]")
    return _TableToJSON(table):gsub("(:[%d]+)%.[%d]+",_r)
end

local function emojid(emoji)
    local str = string.match(emoji, "<?a?(:.*:[0-9]*)>?")
    if str == nil
    then
        local str = ""
        for i = 1, #emoji
        do
            str = str .. string.format("%%%x", emoji:byte(i, i))
        end
        emoji = str
    else
        emoji = str or emoji
    end
    return emoji
end

local handleEvent = discordlib.handleEvent

function discordlib.client(token)
    local client = {}

    client.ws = GWSockets.createWebSocket("wss://gateway.discord.gg/?v=9&encoding=json")

    client.cache = {users = {}, guilds = {}, roles = {}, private_channels = {}}
    client.user = {presence = discordlib.presence()}
    client.events = {}
    client.sequence = 1
    client.sessionID = nil
    client.uid = util.CRC(token)
    client.autoreconnect = true

    function client.on(eventname, id, fn)
        client.events[eventname] = client.events[eventname] or {}
        client.events[eventname][id] = fn
    end

    function client.emitEvent(eventname, ...)
        if not client.events[eventname] then return end

        for k, v in pairs(client.events[eventname]) do
            v(...)
        end
    end

    function client.login()
        if client and client.ws:isConnected() then return end
        client.disconect()
        client.ws:open()
    end

    function client.destroy()
        client.autoreconnect = false
        client.disconect()
    end

    function client.disconect()
        if client.uid
        then
            timer.Remove("discord" .. client.uid .. "heartbeat")
            hook.Remove("Think", "discord" .. client.uid .. "ratelimiter")
        end
        if client and client.ws:isConnected() then
            client.ws:clearQueue()
            client.ws:closeNow()
        end
    end

    function client.ws:onDisconnected()
        client.emitEvent("close")

        if client.autoreconnect
        then
            client.login()
        end
    end

    function client.ws:onError(errMessage)
        client.emitEvent("error", errMessage)
        error(errMessage)
    end

    function client.ws:onMessage(json)
        local payload = JSONToTable(json)

        if payload.s
        then
            client.sequence = payload.s
        end

        if payload.op == 0
        then
            handleEvent(client, payload)
        elseif payload.op == 10
        then
            -- Identifying
            if client.sessionID == nil then
                client.ws:write([[{"op":2,"d":{"token":"${token}","presence":]] .. string.Replace([[{"op":3}]] , "\"null\"", "null") .. [[,"properties":{"$os":"${jit.os}","$browser":"gmod-dapi","$device":"gmod-dapi"}}}]])
            else
                client.ws:write([[{"op":6,"d":{"token":"${token}","session_id":"${client.sessionID}","seq":${client.sequence}}}]])
            end

            timer.Create("discord" .. client.uid .. "heartbeat", payload.d.heartbeat_interval / 1000, 0, function()
                if client.ws:isConnected() then return end
                if client.ACKReceived == false then
                    client.reconnect()
                end

                client.ACKReceived = false
                client.ws:write([[{"op":1,"d":]] .. client.sequence .. [[}]])
            end)

            hook.Add("Think", "discord" .. client.uid .. "ratelimiter", function()
                for i = 1, #client.ratelimiter do
                    local ratelimiter = client.ratelimiter[i]
                    local requests = ratelimiter.requests

                    if ratelimiter.reset < CurTime() then
                        ratelimiter.remaining = ratelimiter.limit
                        ratelimiter.reset = CurTime() + ratelimiter.reset_delay + 0.5
                    end

                    if ratelimiter.remaining == 0 then return end
                    if ratelimiter.remaining == ratelimiter.limit and requests.count == 0 then ratelimiter.reset = CurTime() + ratelimiter.reset_delay + 0.5 end

                    for i = 1, math.min(ratelimiter.remaining, requests.count) do
                        CHTTP(requests:pop())
                        ratelimiter.remaining = ratelimiter.remaining - 1
                    end

                end
            end)
        elseif payload.op == 9 then
            -- Invalid Session
            client.disconect()

            -- session may be resumable 
            if payload.d == true
            then
                return timer.Simple(2, client.disconect)
            end

            client.sessionID = nil
            return client.disconect()
        elseif payload.op == 11
        then
            client.ACKReceived = true
        end
    end

    client.ratelimiter = {
        {   -- send message
            limit = 5,
            remaining = 5,
            reset = CurTime() + 5,
            reset_delay = 5,
            requests = queue()
        },
        {   -- modify channel
            limit = 10,
            remaining = 10,
            reset = CurTime() + 15,
            reset_delay = 15,
            requests = queue()
        },
        {   -- execute webhook
        limit = 5,
        remaining = 5,
        reset = CurTime() + 2,
        reset_delay = 2,
        requests = queue()
        },
        {   -- modify guild member
        limit = 10,
        remaining = 10,
        reset = CurTime() + 15,
        reset_delay = 15,
        requests = queue()
        },
        {   -- kick guild member
        limit = 5,
        remaining = 5,
        reset = CurTime() + 1,
        reset_delay = 1,
        requests = queue()
        },        
        {   -- create guild command
        limit = 5,
        remaining = 5,
        reset = CurTime() + 20,
        reset_delay = 20,
        requests = queue()
        },        
        {   -- edit guild command
        limit = 5,
        remaining = 5,
        reset = CurTime() + 20,
        reset_delay = 20,
        requests = queue()
        },
    }

    function client.setPresence(presence)
        client.ws:write(string.Replace([[{"op":3,"d":]] .. TableToJSON(presence) .. [[}]] , "\"null\"", "null"))
        client.user.presence = presence
    end

    function client.HTTPRequest(endpoint, method, postdata, callback, rate_limiter_id)
        local request = {
            method = method,
            url = "https://discordapp.com/api/v6/" .. endpoint,
            headers = {
                ["Authorization"] = "Bot " .. token,
                ["Content-Type"] = "application/json"
            },
            body = TableToJSON(postdata),
            success = callback and function(code, json, headers)
                callback(code, JSONToTable(json), headers)
            end,
            failed = error
        }

        if rate_limiter_id == false then return CHTTP(request) end

        if rate_limiter_id == nil then
            rate_limiter_id = 1
        end

        client.ratelimiter[rate_limiter_id].requests:push(request)
    end
        
    function client.sendMessage(channelID, msg, callback)
        if istable(msg) then msg.embeds = nil else msg = {content = tostring(msg)} end
        client.HTTPRequest("channels/${channelID}/messages", "POST", msg, callback and function(code,data,headers)
            local error = code != 200

            if !error
            then
                data.author = discordlib.structures.user(client, data.author)
            end

            callback(error, data, headers)
        end, 1)
    end    

    function client.createReaction(channelID = !err, messageID = !err, emoji = !err, callback)
        emoji = emojid(emoji)
        client.HTTPRequest("/channels/${channelID}/messages/${messageID}/reactions/${emoji}/@me", "PUT", {}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.deleteOwnReaction(channelID = !err, messageID = !err, emoji = !err, callback)
        emoji = emojid(emoji)
        client.HTTPRequest("/channels/${channelID}/messages/${messageID}/reactions/${emoji}/@me", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end    
    
    function client.deleteUserReaction(channelID = !err, messageID = !err, emoji = !err, userID = !err, callback)
        emoji = emojid(emoji)
        client.HTTPRequest("/channels/${channelID}/messages/${messageID}/reactions/${emoji}/{$userID}", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end
    
    function client.deleteAllReactions(channelID = !err, messageID = !err, callback)
        client.HTTPRequest("/channels/${channelID}/messages/${messageID}/reactions", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, false)
    end

    function client.deleteAllReactionsForEmoji(channelID = !err, messageID = !err, emoji = !err, callback)
        emoji = emojid(emoji)
        client.HTTPRequest("/channels/${channelID}/messages/${messageID}/reactions/${emoji}", "DELETE", {}, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, false)
    end    

    function client.sendMessageDM(userID, msg, callback)
        if client.cache.private_channels[userID] != nil
        then
            return client.cache.private_channels[userID].send(msg,callback)
        end

        client.HTTPRequest("/users/@me/channels","POST", {recipient_id = userID}, function(code, data, headers)
            local error = code != 200
            if not error
            then
                data = discordlib.structures.channel(client, data)
                client.cache.private_channels[userID] = data
                data.send(msg, callback)
                return
            end
            if callback then callback(error, data, headers) end
        end)
    end

    function client.editMessage(channelID, messageID, msg, callback)
        if istable(msg) then msg.embeds = nil else msg = {content = tostring(msg)} end
        client.HTTPRequest("/channels/${channelID}/messages/${messageID}", "PATCH", msg, callback and function(code,data,headers)
            local error = code != 200

            if !error
            then
                data.author = discordlib.structures.user(client, data.author)
            end

            callback(error, data, headers)
        end, 1)
    end
    
    function client.deleteMessage(channelID, messageID, callback)
        client.HTTPRequest("/channels/${channelID}/messages/${messageID}", "DELETE", {}, callback and function(code,data,headers)
            local error = code != 204

            callback(error, {}, headers)
        end, 1)
    end

    function client.createWebhook(channelID, name, avatar, callback)
        client.HTTPRequest("channels/${channelID}/webhooks", "POST", {
            name = name,
            avatar = avatar
        }, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, false)
    end

    function client.getChannelWebhooks(channelID, callback)
        client.HTTPRequest("channels/${channelID}/webhooks", "GET", {}, callback and function(code, data, headers)
            local error = code != 200

            if not error then
                for k, v in ipairs(data) do
                    data[k] = discordlib.structures.webhook(client, v)
                end
            end

            callback(error, data, headers)
        end, false)
    end

    function client.deleteWebhook(webhookID, callback)
        client.HTTPRequest("webhooks/" .. webhookID, "DELETE", {}, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, false)
    end

    function client.executeWebhook(webhookID, webhookToken, table, callback)
        client.HTTPRequest("webhooks/${webhookID}/" .. webhookToken, "POST", table, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, 3)
    end

    function client.modifyChannel(channelID, table, callback)
        client.HTTPRequest("/channels/${channelID}", "PATCH", table, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, 2)
    end    
    
    function client.modifyGuildChannel(guildID, table, callback)
        client.HTTPRequest("/guilds/${guildID}/channels", "PATCH", table, callback and function(code, data, headers)
            callback(code != 200, data, headers)
        end, 2)
    end

    function client.modifyGuildMember(guildID, memberID, table, callback)
        client.HTTPRequest("/guilds/${guildID}/members/${memberID}", "PATCH", table, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, 4)
    end

    function client.kickMember(guildID, memberID, callback)
        client.HTTPRequest("/guilds/${guildID}/members/${memberID}", "DELETE", nil, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, 5)
    end    
    
    function client.banMember(guildID, memberID, reason, deleteMessageDays, callback)
        client.HTTPRequest("/guilds/${guildID}/bans/${memberID}", "PUT", {reason = reason, delete_message_days = deleteMessageDays}, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.unbanMember(guildID, memberID, callback)
        client.HTTPRequest("/guilds/${guildID}/bans/${memberID}", "DELETE", nil, callback and function(code, data, headers)
            callback(code != 204, data, headers)
        end, false)
    end

    function client.getGuildBans(guildID, callback)
        client.HTTPRequest("/guilds/${guildID}/bans", "GET", nil, callback and function(code, data, headers)
            local error = code != 200
            if !error
            then
                for k,v in ipairs(data)
                do
                    data[k].user = discordlib.structures.user(client, v.user)
                end
            end
            callback(error, data, headers)
        end, false)
    end


    function client.getGuildCommands(guildID, callback)
        client.HTTPRequest("/applications/${client.user.id}/guilds/${guildID}/commands", "GET", {}, callback and function(code, data, headers)
            callback(code ~= 200, data, headers)
        end, false)
    end

    function client.createGuildCommand(command, guildID, callback)
        client.HTTPRequest("/applications/${client.user.id}/guilds/${guildID}/commands", "POST", command, callback and function(code, data, headers)
            callback(code ~= 200, data, headers)
        end, 6)
    end

    function client.editGuildCommand(command, guildID, commandID, callback)
        client.HTTPRequest("/applications/${client.user.id}/guilds/${guildID}/commands/${commandID}", "PATCH", command, callback and function(code, data, headers)
            local error = code ~= 200

            if not error then
                data.guild_id = guildID
            end

            callback(error, data, headers)
        end, 7)
    end

    function client.deleteGuildCommand(guildID, commandID, callback)
        client.HTTPRequest("/applications/${client.user.id}/guilds/${guildID}/commands/" .. commandID, "DELETE", {}, callback and function(code, data, headers)
            callback(code ~= 204, data, headers)
        end, false)
    end


    return client
end