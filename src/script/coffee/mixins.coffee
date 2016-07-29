# Make the mixins namespace.
Game.Mixins = {}

Game.Mixins.MessageRecipient =
  name: "MessageRecipient"
  init: (template) ->
    @_messages = []

  getMessages: ->
    @_messages

  recieveMessage: (message) ->
    @_messages.push(message)

  clearMessage: () ->
    @_messages = []

Game.Mixins.BlocksMovement =
  name: "BlocksMovement"
  init: () ->
    @_blocksMovement = true
