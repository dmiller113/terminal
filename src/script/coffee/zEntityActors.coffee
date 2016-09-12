Game.playerTemplate = {
  name: "Player",
  symbol: "@",
  foreground: "white",
  background: "black",
  atkValue: 10,
  maxHp: 40,
  sightRadius: 8,
  scan: 3,
  offense: 3,
  hardening: 3,
  stealth: 3,
  abilities: {
    C: Game.AbilityRepository.create("protobump")
    R: null
    "1": null
    "2": null
    "3": null
    "4": null
  }
  mixins: [Game.Mixins.Movable, Game.Mixins.PlayerActor,
    Game.Mixins.Abilities.SimpleAbilityUser, Game.Mixins.MessageRecipient,
    Game.Mixins.SimpleDestructible, Game.Mixins.Sight, Game.Mixins.Attributes.Scan,
    Game.Mixins.Attributes.Hardening, Game.Mixins.Attributes.Offense,
    Game.Mixins.Attributes.Stealth, Game.Mixins.ActiveMemory],
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
  maxHp: 20
  hardening: 20
  mixins: [Game.Mixins.Wander, Game.Mixins.SimpleDestructible,
           Game.Mixins.Attributes.Hardening]
})
