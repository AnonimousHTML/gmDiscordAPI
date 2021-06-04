<h1 align="center">Responce Enums</h1>
<h5 align="center">

`discordlib.response`

| Name         |    Value       | Description  | 
| -------------| -------------  | -------------|
| Pong                             |  1 | ACK a Ping | 
| ChannelMessageWithSource         |  4 | respond to an interaction with a message |
| DeferredChannelMessageWithSource |  5 | ACK an interaction and edit a response later, the user sees a loading state |
| DeferredUpdateMessage*            |  6 | for components, ACK an interaction and edit the original message later; the user does not see a loading state |
| UpdateMessage*                    |  7 | for components, edit the message the component was attached to |

</h5>

* \* Only valid for [component](components.md)-based interactions