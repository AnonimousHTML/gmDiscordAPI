
<h1 align="center">Events</h1>
<h1 align="center">Subscrive to event example</h1>

```
local discordClient = discordlib.client(token)
discordClient.on("Ready", "init", function(data) end)
```

<h3 align="center">Ready</h3>

---

* table data

<h1></h1>


<h3 align="center">GuildCreate</h3>

---

* [guild](guild.md) guild

<h1></h1>

<h3 align="center">GuildMemberAdd</h3>

---

* [guild](guild.md) guild
* [member](member.md) member
<h1></h1>

<h3 align="center">GuildMemberUpdate</h3>

---

* [guild](guild.md) guild
* [member](member.md) member
* [member](member.md) oldMemberData `! always check for nil !`
<h1></h1>


<h3 align="center">GuildMemberRemove</h3>

---

* [guild](guild.md) guild
* [member](member.md) member `! always check for nil !`

<h1></h1>

<h3 align="center">ChannelCreate</h3>

---

* [channel](channel.md) channel

<h1></h1>

<h3 align="center">ChannelUpdate</h3>

---

* [channel](channel.md) channel
* [channel](channel.md) oldChannelData `! always check for nil !`
<h1></h1>

<h3 align="center">ChannelDelete</h3>

---

* [channel](channel.md) channel  `! always check for nil !`
<h1></h1>

<h3 align="center">MessageCreate</h3>

---

* table message
<h1></h1>

<h3 align="center">MessageUpdate</h3>

---

* table message
<h1></h1>

<h3 align="center">MessageDelete</h3>

---

* table data
<h1></h1>

<h3 align="center">GuildRoleCreate</h3>

---

* [guild](guild.md) guild
* table role
<h1></h1>

<h3 align="center">GuildRoleUpdate</h3>

---

* [guild](guild.md) guild
* table role
* table oldRoleData `! always check for nil !`
<h1></h1>

<h3 align="center">GuildRoleDelete</h3>

---

* [guild](guild.md) guild
* table role `! always check for nil !`
<h1></h1>

<h3 align="center">GuildEmojisUpdate</h3>

---

* [guild](guild.md) guild

<h1></h1>

<h3 align="center">MessageReactionAdd</h3>

---

* [emoji](emoji.md) emoji
* {[user](user.md) or [member](member.md) or string} user
* table data

<h1></h1>

<h3 align="center">MessageReactionRemove</h3>

---

* [emoji](emoji.md) emoji
* {[user](user.md) or [member](member.md) or string} user
* table data

<h1></h1>

<h3 align="center">WebhooksUpdate</h3>

---

* [guild](guld.md) guld
* [channel](channel.md) channel

<h1></h1>

<h3 align="center">ButtonInteraction</h3>

---

* [interaction](interaction.md) data


<h1></h1>

<h3 align="center">SlashCommandInteraction</h3>

---
* [interaction](interaction.md) data

<h1></h1>