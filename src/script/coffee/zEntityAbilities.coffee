Game.AbilityRepository = new Repository('abilities', Entity)

Game.AbilityRepository.define({
  name: "ProtoBump"
  symbol: "?"
  foreground: "white",
  background: "black",
  memory: 1,
  effect: (target, origin, stats) ->
    damage = {type: "normal", amount: 10}
    origin.raiseEvent('onAttacking', {damage: damage, target: target})
    target.raiseEvent('onAttack', {damage: damage, source: origin})
    target.raiseEvent("takeDamage", {source: origin, damage: damage})
    origin.raiseEvent('deltDamage', {damage: damage, target: target})

  mixins: [Game.Mixins.ConsumesMemory, Game.Mixins.HasEffect]
})
