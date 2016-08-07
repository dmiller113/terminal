Game.playerTemplate = {
  name: "Player",
  symbol: "@",
  foreground: "white",
  background: "black",
  atkValue: 10,
  maxHp: 40,
  itemSlots: 26,
  sightRadius: 8,
  mixins: [Game.Mixins.Movable, Game.Mixins.PlayerActor,
    Game.Mixins.SimpleAttacker, Game.Mixins.MessageRecipient,
    Game.Mixins.SimpleDestructible, Game.Mixins.Inventory,
    Game.Mixins.PlayerPickup, Game.Mixins.Sight],
}

Game.EntityRepository = new Repository('entities', Entity)

Game.EntityRepository.define({
  name: "Fungus",
  symbol: "F",
  foreground: "chartreuse",
  mixins: [Game.Mixins.FungusActor, Game.Mixins.FragileDestructible]
})

Game.EntityRepository.define({
  name: "Goblin",
  symbol: "G",
  foreground: "MediumSeaGreen",
  mixins: [Game.Mixins.Wander, Game.Mixins.FragileDestructible]
})
