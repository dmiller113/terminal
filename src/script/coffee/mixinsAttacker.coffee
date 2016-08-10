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
      damage = {
        amount: rDmg,
        type: "normal",
      }
      @raiseEvent('onAttacking', {damage: damage, target: target})
      target.raiseEvent('onAttack', {damage: damage, source: @})
      target.raiseEvent('takeDamage', {damage: damage, source: @})
      @raiseEvent('deltDamage', {damage: damage, target: target})
      true
    else
      false

Game.Mixins.FireAttacker =
  name: "FireAttacker"
  groupName: "Attacker"
  listeners:
    onAttacking:
      priority: 75
      func: (type, dict) ->
        dict.damage.amount += 5
        dict.damage.type += ',fire'
