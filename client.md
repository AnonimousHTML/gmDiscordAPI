<h1 align="center">Methods</h1>
<h3 align="center"> void client.on</h3>

---
* [event](events.md) eventname
* string id
* function fn

<h1></h1>

<h1></h1>
<h3 align="center"> void client.login</h3>

---

<h1></h1>
<h3 align="center"> void client.destroy</h3>

---

<h1></h1>


<h3 align="center"> void  client.setPresence</h3>

---

<h2 align="center"> Warning</h2>

Available after [Ready event](events.md#Ready)

---
* [presence](presence.md) presence
<h1></h1>


<h3 align="center"> void client.createReaction</h3>

---
* string channelID
* string messageID 
* string emoji
* function !callback
<h1></h1>


<h3 align="center"> void client.deleteOwnReaction</h3>

---
* string channelID
* string messageID 
* string emoji
* function !callback
<h1></h1>

<h3 align="center"> void client.deleteUserReaction</h3>

---
* string channelID
* string messageID 
* string emoji
* string userID
* function !callback
<h1></h1>

<h3 align="center"> void client.deleteAllReactions</h3>

---
* string channelID
* string messageID 
* function !callback
<h1></h1>


<h3 align="center"> void client.deleteAllReactionsForEmoji</h3>

---
* string channelID
* string messageID 
* string emoji
* function !callback
<h1></h1>