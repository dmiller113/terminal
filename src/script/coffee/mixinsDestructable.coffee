Game.Mixins.FragileDestructible =
  name: "FragileDestructible"
  groupName: "Destructible"
  init: () ->
    @_hp = 0

  takeDamage: (actor, damage) ->
    @_hp -= damage
    # If we have less than 0 hp than remove ourselves
    if @_hp < 0
      @getMap().removeEntity(@)

# Generic Destructible
Game.Mixins.SimpleDestructible =
  name: "SimpleDestructible"
  groupName: "Destructible"
  init: (template) ->
    # Defaults to 10hp, but takes it from the template
    @_maxHp = template['maxHp'] || 10
    # Defaults to full health, but can take it from the template
    @_hp = template['Hp'] || @_maxHp
    # Defaults to 0 def, but takes it from template
    @_defValue = template['defValue'] || 0

  getHp: () ->
    @_hp

  getMaxHp: () ->
    @_maxHp

  getDef: ->
    @_defValue

  takeDamage: (actor, damage) ->
    realDamage = Math.max(1, (damage - @_defValue))
    if @hasMixin("MessageRecipient")
      Game.sendMessage(@, Game.Messages.damageMessage,
        [actor.describeA(true), realDamage])

    @_hp -= realDamage
    # If we have less than 0 hp than remove ourselves
    if @_hp < 0
      if @hasMixin("MessageRecipient") and @hasMixin("PlayerActor")
        Game.sendMessage(@, Game.Messages.dieMessage)
      else if actor.hasMixin("MessageRecipient")
          Game.sendMessage(actor, Game.Messages.killMessage, [actor.describeA(True), @describeA()])
      # Currently killing the player causes a massive problem with the Scheduler
      # Don't kill the player yet.
      if !@hasMixin("PlayerActor")
        @getMap().removeEntity(@)
