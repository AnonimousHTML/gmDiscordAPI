discordlib.style = {
    Primary     = 1,
    Secondary   = 2,
    Success     = 3,
    Danger      = 4,
    Link        = 5,
}

local function emojid(emoji)
    if emoji
    then
        local animated,name,id = string.match(emoji, "<?(a?):(.*):([0-9]*)>?")
        if name != nil
        then
            emoji = {name = name,id = id, animated = animated == "a"}
        else
            emoji = {name = emoji}
        end
    end

    return emoji
end

function discordlib.component()
    local component = {type = 1, components = {}}

    function component.addButton(customID = !err, style = !err, label = !err, emoji, disabled)
        if #component.components > 5 then error("Exceeded the limit on the number of buttons(6)") end
        component.components[#component.components + 1] = {
            type = 2,style = style,label = label, emoji = emoji and emojid(emoji), disabled = disabled, custom_id = customID
        }

        return component
    end
    
    
    function component.addLinkButton(url = !err, label = !err, emoji, disabled)
        if #component.components > 5 then error("Exceeded the limit on the number of buttons(6)") end
        component.components[#component.components + 1] = {
            type = 2,style = 5,label = label, url = url, emoji = emoji and emojid(emoji), disabled = disabled
        }

        return component
    end

    return component
end