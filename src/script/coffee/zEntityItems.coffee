Game.ItemRepository = new Repository('items', Entity)

Game.ItemRepository.define({
  name: "Data",
  symbol: '=',
  foreground: "white",
  background: "black",
  useEffect: (target) ->
    target.raiseEvent("takeDamage", {source: @, damage: {type: "focused", amount: 41}})

  mixins: [Game.Mixins.WalkoverEffectItem]
})

Game.ItemRepository.define({
  name: "Offensive Data",
  symbol: '=',
  foreground: "red",
  background: "black",
  mixins: [Game.Mixins.WalkoverPickupItem]
})

Game.ItemRepository.define({
  name: "Defensive Data",
  symbol: '=',
  foreground: "cyan",
  background: "black",
  mixins: [Game.Mixins.WalkoverPickupItem]
})

Game.ItemRepository.define({
  # This is a terrible name
  name: "Utility Data",
  symbol: '=',
  foreground: "green",
  background: "black",
  mixins: [Game.Mixins.WalkoverPickupItem]
  })
