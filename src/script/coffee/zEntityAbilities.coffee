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

Game.AbilityRepository.define({
  name: "ProtoRanged"
  key: ROT.VK_F
  symbol: "?"
  memory: 1
  okFunction: (x, y, map, entity) ->
    target = map.getEntityAt(x, y)
    stats = {}
    entity.raiseEvent("getStats", stats)
    entity.raiseEvent("useEffect", {target, origin: entity, stats})
  effect: (target, origin, stats) ->
    damage = {type: normal, amount: 5}
    origin.raiseEvent('onAttacking', {damage: damage, target: target})
    target.raiseEvent('onAttack', {damage: damage, source: origin})
    target.raiseEvent("takeDamage", {source: origin, damage: damage})
    origin.raiseEvent('deltDamage', {damage: damage, target: target})
  keyFunction: (actor, offsets) ->
    screen = Game.Screen.targetEntityScreen
    screen.setup(actor, actor.getX(), actor.getY(), offsets.x, offsets.y)
    Game.Screen.playScreen.setSubScreen(screen)

  mixins: [Game.Mixins.ConsumesMemory, Game.Mixins.HasEffect,
           Game.Mixins.KeyResponder]
})
