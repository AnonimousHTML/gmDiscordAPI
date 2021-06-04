discordlib.response = {
    Pong                             = 1,
    ChannelMessageWithSource         = 4,
    DeferredChannelMessageWithSource = 5,
    DeferredUpdateMessage            = 6,
    UpdateMessage                    = 7,
}

function discordlib.structures.interaction(client, interaction)

    function interaction.response(type = !err, msg, callback)
        if istable(msg) then msg.embeds = nil elseif msg !=nil then msg = {content = tostring(msg)} end
        client.HTTPRequest("interactions/${interaction.id}/${interaction.token}/callback", "POST", {
            type = type,
            data = msg
        }, callback and function(code, data, headers)
            callback(code ~= 204, data, headers)
        end)
    end

    function interaction.editResponse(msg = !err, callback)
        if istable(msg) then msg.embeds = nil else msg = {content = tostring(msg)} end
        client.HTTPRequest("webhooks/${client.user.id}/${interaction.token}/messages/@original", "PATCH", msg, callback and function(code, data, headers)
            callback(code ~= 200, data, headers)
        end)
    end

    function interaction.deleteResponse()
        client.HTTPRequest("webhooks/" .. client.user.id .. "/" .. interaction.token .. "/messages/@original", "DELETE", {}, callback and function(code, data, headers)
            callback(code ~= 204, data, headers)
        end)
    end

    return interaction
end