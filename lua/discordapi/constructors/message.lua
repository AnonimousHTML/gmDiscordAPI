

function discordlib.message()
    local message = {}

    function message.setText(text = !err)
        message.content = text
        return message
    end

    function message.addEmbed(embed = !err)
        message.embeds = message.embeds or {}
        message.embeds[#message.embeds + 1] = embed
        message.embed = embed
        return message
    end

    function message.addComponents(components = !err)
        message.components = message.components or {}
        if #message.components > 5 then error("Exceeded the limit on the number of components(6)") end
        message.components[#message.components + 1] = components
        return message
    end

    return message
end