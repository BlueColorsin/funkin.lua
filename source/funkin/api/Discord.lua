---
--- @diagnostic disable: inject-field
--- @type funkin.libs.DiscordRPC
---
DiscordRPC = Flora.import("funkin.libs.DiscordRPC")

---
--- @class funkin.api.Discord
---
local Discord = {}

---
--- @protected
--- @type number
---
Discord._updateTimer = 0.0

function Discord.init()
    DiscordRPC.initialize("1290899086911733771", true)
    DiscordRPC.ready = function(userID, username, discriminator, avatar)
        Flora.log:success("Connected as " .. username .. " (" .. userID .. ")")
    end
    Flora.signals.preUpdate:connect(function()
        DiscordRPC.runCallbacks()
    end)
    Flora.signals.preQuit:connect(function()
        DiscordRPC.shutdown()
    end)
end

function Discord.changePresence(data)
    DiscordRPC.updatePresence({
        state = data.state,
        details = data.details,
        largeImageKey = data.icon and data.icon or "icon",
        largeImageText = data.largeImageText and data.largeImageText or "funkin.lua"
    })
end

return Discord