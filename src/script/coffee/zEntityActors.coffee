Game.playerTemplate = {
  name: "Player",
  symbol: "@",
  foreground: "white",
  background: "black",
  atkValue: 10,
  maxHp: 40,
  itemSlots: 26,
  sightRadius: 8,
  scan: 3,
  offense: 3,
  hardening: 3,
  stealth: 3,
  mixins: [Game.Mixins.Movable, Game.Mixins.PlayerActor,
    Game.Mixins.SimpleAttacker, Game.Mixins.MessageRecipient,
    Game.Mixins.SimpleDestructible, Game.Mixins.Inventory,
    Game.Mixins.PlayerPickup, Game.Mixins.Sight, Game.Mixins.Attributes.Scan,
    Game.Mixins.Attributes.Hardening, Game.Mixins.Attributes.Offense,
    Game.Mixins.Attributes.Stealth,],
}

Game.EntityRepository = new Repository('entities', Entity)

Game.EntityRepository.define({
  name: "Fungus",
  symbol: "F",
  foreground: "chartreuse",
  hardening: 15,
  mixins: [Game.Mixins.FungusActor, Game.Mixins.FragileDestructible,]
})

Game.EntityRepository.define({
  name: "Goblin",
  symbol: "G",
  foreground: "MediumSeaGreen",
  mixins: [Game.Mixins.Wander, Game.Mixins.FragileDestructible]
})
