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
  foreground: "#FF0077",
  useEffect: scaledHealEffect(15)
  mixins: [Game.Mixins.WalkoverEffectItem]
})

Game.ItemRepository.define({
  name: "Recover",
  symbol: '=',
  foreground: "#FF274E",
  useEffect: scaledHealEffect(35)
  mixins: [Game.Mixins.WalkoverEffectItem]
})

Game.ItemRepository.define({
  name: "Restore",
  symbol: '=',
  foreground: "maroon",
  useEffect: scaledHealEffect(50)
  mixins: [Game.Mixins.WalkoverEffectItem]
})
