Game.Mixins.PlayerActor = {
  name: "PlayerActor",
  groupName: "Actor",
  act: () ->
    Game.refresh()
    @getMap().getEngine().lock()
    @clearMessage()
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
  init: (template) ->
    if @_attributes == undefined
      @_attributes = {}
    @_attributes.offense = template['offense'] || 1
  getHardening: () ->
    if @_attributes?
      @_attributes.offense
}

Game.Mixins.Attributes.Scan = {
  name: "AttributeScan",
  groupName: "Attribute",
  init: (template) ->
    if @_attributes == undefined
      @_attributes = {}
    @_attributes.scan = template['scan'] || 1
  getHardening: () ->
    if @_attributes?
      @_attributes.scan
}

Game.Mixins.Attributes.Stealth = {
  name: "AttributeStealth",
  groupName: "Attribute",
  init: (template) ->
    if @_attributes == undefined
      @_attributes = {}
    @_attributes.stealth = template['stealth'] || 1
  getHardening: () ->
    if @_attributes?
      @_attributes.stealth
}
