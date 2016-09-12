# Make the mixins namespace.
Game.Mixins = {}

Game.Mixins.MessageRecipient =
  name: "MessageRecipient"
  listeners:
    deltDamage:
      priority: 15
      func: (type, dict) ->
        target = dict.target
        damage = dict.damage.amount
        message = Game.parseMessage(Game.Messages.attackMessage,
          [@describe(), target.describeA(false), damage])
        if damage < 1
          message = Game.parseMessage(Game.Messages.noDamage,
            [@describeA(true), target.describeA(false)])
        @recieveMessage(message)

    takeDamage:
      priority: 10
      func: (type, dict) ->
        damage = dict.damage.amount
        @recieveMessage(Game.parseMessage(Game.Messages.damageMessage,
          [dict.source.describe(), damage]))

    onDeath:
      priority: 15
      func: (type, dict) ->
        source = dict.source
        if @hasMixin("PlayerActor")
          @recieveMessage(Game.parseMessage(Game.Messages.dieMessage))
        else
          @recieveMessage(Game.parseMessage(Game.Messages.killMessage, [source.describeA(True), @describeA()]))

    healDamage:
      priority: 10
      func: (type, dict) ->
        @recieveMessage(Game.parseMessage(Game.Messages.healDamage, [
          @describe(), dict.amountHealed
        ]))

    walkedOver:
      priority: 10
      func: (type, dict) ->
        @recieveMessage(Game.parseMessage(Game.Messages.walkoverItem, [
          @describe(), dict.item.describeA(false)
        ]))

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
