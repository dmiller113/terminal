Game.Mixins.FragileDestructible =
  name: "FragileDestructible"
  groupName: "Destructible"
  listeners:
    takeDamage:
      priority: 25
      func: (type, dict) ->
        damage = dict.damage.amount
        source = dict.source
        @_hp -= damage
        # If we have less than 0 hp than remove ourselves
        if @_hp < 0
          source.raiseEvent('onKill')
          @raiseEvent('onDeath')
    # Destructable handles removing the entity
    onDeath:
      priority: 25
      func: (type, dict) ->
        @getMap().removeEntity(@)

  init: () ->
    @_hp = 0

# Generic Destructible
Game.Mixins.SimpleDestructible =
  name: "SimpleDestructible"
  groupName: "Destructible"
  listeners:
    takeDamage:
      priority: 25
      func: (type, dict) ->
        damage = dict.damage.amount
        source = dict.source

        @_hp -= damage
        # If we have less than 0 hp than remove ourselves
        if @_hp < 0
          source.raiseEvent('onKill', {damage: damage, target: @})
          @raiseEvent('onDeath', {source: source})

    onDeath:
      priority: 25
      func: (type, dict) ->
        # Currently killing the player causes a massive problem with the Scheduler
        # Don't kill the player yet.
        if !@hasMixin("PlayerActor")
          @getMap().removeEntity(@)

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
