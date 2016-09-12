Game.Mixins.PlayerActor = {
  name: "PlayerActor",
  groupName: "Actor",
  act: () ->
    Game.refresh()
    @getMap().getEngine().lock()
}

Game.Mixins.FungusActor = {
  name: "FungusActor",
  groupName: "Actor",
  init: () ->
    @_growthsRemaining = 5
  act: () ->
    growChance = Math.random()
    if @_growthsRemaining > 0 and growChance < 0.02
      xOffset = Math.floor(Math.random() * 3) - 1
      yOffset = Math.floor(Math.random() * 3) - 1
      xCoord = @getX() + xOffset
      yCoord = @getY() + yOffset

      if @getMap().isEmptyFloor(xCoord, yCoord)
        entity = Game.EntityRepository.create('fungus')
        entity.setXY(xCoord, yCoord)
        # Stop it from pooping all over my ram
        entity._growthsRemaining = @_growthsRemaining -= 1
        @getMap().addEntity(entity)
}

Game.Mixins.Wander = {
  name: "WanderActor",
  groupName: "Actor",
  act: () ->
    xOffset = Math.floor(Math.random() * 3) - 1
    yOffset = Math.floor(Math.random() * 3) - 1
    xCoord = @getX() + xOffset
    yCoord = @getY() + yOffset

    if @getMap().isEmptyFloor(xCoord, yCoord)
      @setXY(xCoord, yCoord)
}

Game.Mixins.Sight = {
  name: "Sight",
  groupName: "Sight",
  init: (template) ->
    @_sightRadius = template['sightRadius'] || 5
  getSightRadius: () ->
    @_sightRadius
}

Game.Mixins.Attributes = if Game.Mixins.Attributes? then Game.Mixins.Attributes else {}
Game.Mixins.Attributes.Hardening = {
  name: "AttributeHardening",
  groupName: "Attribute",
  listeners:
    takeDamage:
      priority: 50
      func: (type, dict) ->
        # Hardening reduces nonFocused Damage, 1:1
        damage = dict.damage.amount
        type = dict.damage.type
        if type != 'focused'
          damage = Math.max(damage - @getHardening(), 0)
        dict.damage.amount = damage
    getStats:
      priority: 75
      func: (type, dict) ->
        stats = dict.stats
        stats.Hardening = @getHardening()

  init: (template) ->
    if @_attributes == undefined
      @_attributes = {}
    @_attributes.hardening = template['hardening'] || 1
  getHardening: () ->
    if @_attributes?
      @_attributes.hardening
}

Game.Mixins.Attributes.Offense = {
  name: "AttributeOffense",
  groupName: "Attribute",
  listeners:
    getStats:
      priority: 75
      func: (type, dict) ->
        stats = dict.stats
        stats.Offense = @getOffense()

  init: (template) ->
    if @_attributes == undefined
      @_attributes = {}
    @_attributes.offense = template['offense'] || 1
  getOffense: () ->
    if @_attributes?
      @_attributes.offense
}

Game.Mixins.Attributes.Scan = {
  name: "AttributeScan",
  groupName: "Attribute",
  listeners:
    getStats:
      priority: 75
      func: (type, dict) ->
        stats = dict.stats
        stats.Scan = @getScan()

  init: (template) ->
    if @_attributes == undefined
      @_attributes = {}
    @_attributes.scan = template['scan'] || 1
  getScan: () ->
    if @_attributes?
      @_attributes.scan
}

Game.Mixins.Attributes.Stealth = {
  name: "AttributeStealth",
  groupName: "Attribute",
  listeners:
    getStats:
      priority: 75
      func: (type, dict) ->
        stats = dict.stats
        stats.Stealth = @getStealth()

  init: (template) ->
    if @_attributes == undefined
      @_attributes = {}
    @_attributes.stealth = template['stealth'] || 1
  getStealth: () ->
    if @_attributes?
      @_attributes.stealth
}

# Ability mixins.
Game.Mixins.Abilities = {}
Game.Mixins.Abilities.SimpleAbilityUser =
  name: "AbilityUserSimple"
  groupName: "AbilityUser"
  listeners:
    useContact:
      priority: 25
      # Dict should contain .target with the target of the ability and .stats
      # with the user's stats.
      func: (type, dict) ->
        activeMemory = {}
        @raiseEvent("getAbilities", activeMemory)
        if "C" of activeMemory.abilities and "raiseEvent" of activeMemory.abilities.C
          activeMemory.abilities.C.raiseEvent("useEffect", {
            target: dict.target,
            origin: @,
            stats: dict.stats,
          })
