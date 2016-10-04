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
  effect: (target, origin, stats) ->
    damage = {type: "normal", amount: 5}
    origin.raiseEvent('onAttacking', {damage: damage, target: target})
    target.raiseEvent('onAttack', {damage: damage, source: origin})
    target.raiseEvent("takeDamage", {source: origin, damage: damage})
    origin.raiseEvent('deltDamage', {damage: damage, target: target})
  keyFunction: (actor, offsets) ->
    self = @
    okFunction = (x, y, map, entity) ->
      target = map.getEntityAt(x, y)
      stats = {}
      entity.raiseEvent("getStats", {stats})
      self.raiseEvent("useEffect", {target, origin: entity, stats})
    isOkFunction = (x, y, map, actor) ->
      target = map.getEntityAt(x, y)
      return (target && target.hasMixin("Destructible"))
    screen = Game.Screen.targetEntityScreen
    screen.setup(actor, actor.getX(), actor.getY(), offsets.x, offsets.y)
    screen.setSelectFunction({okFunction, isOkFunction})
    Game.Screen.playScreen.setSubScreen(screen)

  mixins: [Game.Mixins.ConsumesMemory, Game.Mixins.HasEffect,
           Game.Mixins.KeyResponder]
})
