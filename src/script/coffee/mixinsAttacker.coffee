Game.Mixins.SimpleAttacker =
  name: "SimpleAttacker"
  groupName: "Attacker"
  init: (template) ->
    # Defaults to 1 attack, but takes it from the template
    @_atkValue = template['atkValue'] || 1

  getAttack: ->
    @_atkValue

  attack: (target) ->
    if target.hasMixin("Destructible")
      # Have a random chance to do from .5 to 1.5x the attack value.
      rDmg = Math.max(1, Math.floor((Math.random() + .5) * @_atkValue))
      target.takeDamage(@, rDmg)
      if @hasMixin("MessageRecipient")
        Game.sendMessage(@, Game.Messages.attackMessage,
          [@describeA(true), target.describeA(false), rDmg])
      true
    else
      false
