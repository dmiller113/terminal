Game.ItemRepository = new Repository('items', Entity)

Game.ItemRepository.define({
  name: "Data",
  symbol: '=',
  foreground: "white",
  background: "black",
  useEffect: (target) ->
    if target.hasMixin("Destructible")
      target.takeDamage(@, 41)

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
