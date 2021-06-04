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

    function component.addButton(customID = !err, style = !err, label = !err, emoji, disabled = !err)
        if #component.components > 5 then error("Exceeded the limit on the number of buttons(6)") end
        component.components[#component.components + 1] = {
            type = 2,style = style,label = label, emoji = emoji and emojid(emoji), disabled = disabled, custom_id = customID
        }

        return component
    end
    
    // ['components'] : [1] = '0' ?????? wtf discord
    //function component.addLinkButton(label = !err, url = !err, emoji, disabled = !err, customID = !err)
    //    if #component.components > 5 then error("Exceeded the limit on the number of buttons(6)") end
    //    component.components[#component.components + 1] = {
    //        type = 2,style = 4,label = label, url = url, emoji = emoji and emojid(emoji), disabled = disabled, custom_id = customID
    //    }

    //    return component
    //end

    return component
end