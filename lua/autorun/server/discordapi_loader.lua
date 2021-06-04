if gproclib == nil
then
    return error("DiscordAPI: Missing dependencies https://github.com/devonium/gproc")
end

if !pcall(require, "chttp") then return error("DiscordAPI: Missing dependencies https://github.com/timschumi/gmod-chttp") end
if !pcall(require, "gwsockets") then return error("DiscordAPI: Missing dependencies https://github.com/FredyH/GWSockets") end
discordlib = {structures = {}}
gproclib.setConstant("DISCORD_DEBUG", file.Exists("dsdebug.txt", "DATA") or nil)


for k,file in ipairs(file.Find("discordapi/*.lua", "LUA"))
do
    gproclib.include("discordapi/" .. file)
end