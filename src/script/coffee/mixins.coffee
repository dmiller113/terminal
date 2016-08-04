# Make the mixins namespace.
Game.Mixins = {}

Game.Mixins.MessageRecipient =
  name: "MessageRecipient"
  listeners:
    onAttacking:
      priority: 15
      func: (type, dict) ->
        target = dict.target
        damage = dict.damage.amount
        @recieveMessage(Game.parseMessage(Game.Messages.attackMessage,
          [@describeA(true), target.describeA(false), damage]))

    takeDamage:
      priority: 15
      func: (type, dict) ->
        damage = dict.damage.amount
        @recieveMessage(Game.parseMessage(Game.Messages.damageMessage,
          [@describeA(true), damage]))

    onDeath:
      priority: 15
      func: (type, dict) ->
        source = dict.source
        if @hasMixin("PlayerActor")
          @recieveMessage(Game.parseMessage(Game.Messages.dieMessage))
        else
          @recieveMessage(Game.parseMessage(Game.Messages.killMessage, [source.describeA(True), @describeA()]))


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
