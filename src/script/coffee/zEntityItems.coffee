Game.ItemRepository = new Repository('items', Entity)

Game.ItemRepository.define({
  name: "Data",
  symbol: '=',
  foreground: "white",
  background: "black",
  useEffect: (target) ->
    target.raiseEvent("takeDamage", {source: @, damage: {type: "focused", amount: 20}})

  mixins: [Game.Mixins.WalkoverEffectItem]
})

scaledHealEffect = (percent) ->
  return (target) ->
    target.raiseEvent("healDamagePercent", {source: @, percent: percent || 10} )

Game.ItemRepository.define({
  name: "Repair",
  symbol: '=',
  foreground: "crimson",
  background: "black",
  useEffect: scaledHealEffect(15)
  mixins: [Game.Mixins.WalkoverEffectItem]
})

Game.ItemRepository.define({
  # This is a terrible name
  name: "Utility Data",
  symbol: '=',
  foreground: "green",
  background: "black",
  mixins: [Game.Mixins.WalkoverPickupItem]
  })
