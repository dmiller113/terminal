# Allows items to stack
Game.Mixins.isStackable =
  name: "isStackable"
  init: () ->
    @_isStackable = true


# Allows an actor to hold items
Game.Mixins.Inventory =
  name: "Inventory"
  groupName: "Inventory"
  init: (template) ->
    # Ten slot default
    @_itemSlots = Math.max(Math.min((template.itemSlots || 10), 26), 1)

    # Object, yay
    @_inventory = {}

    for x in [65..(64+@_itemSlots)]
      @_inventory[String.fromCharCode(x)] = undefined

  getItems: () ->
    return @_inventory

  getItem: (letter) ->
    return @_inventory[letter]

  inventorySlotsOpen: () ->
    count = 0
    for key, value of @_inventory
      if !(value?)
        count += 1
    count

  addToInventory: (item) ->
    # Not sure how to handle stacking items yet.
    # Probably arrays. Maybe.
    if @inventorySlotsOpen() == 0
      if @hasMixin("MessageRecipient")
        Game.sendMessage(@, Game.Messages.FullInventory)
      return false

    for key, value of @_inventory
      if !(value?)
        @_inventory[key] = item
        return true

  removeFromInventory: (letter) ->
    if letter of @_inventory
      @_inventory[letter] = undefined
      return true
    return false

  dropFromInventory: (letter) ->
    if letter of @_inventory
      if @_map
        @_inventory[letter].setXY(@getXY())
        @_map.addEntity(@_inventory[letter])
        @removeFromInventory(letter)


Game.Mixins.ActiveMemory =
  listeners:
    hasMemory:
      priority: 50
      # Dict should be an Object.
      func: (type, dict) ->
        result = {usedMemory: 0}
        @raiseEvent("checkMemory", result)
        dict.hasMemory = result.usedMemory < @_maxMemory

  init: (template) ->
    # Ten MEM max by default, overridable by template
    @_maxMemory = template.maxMemory || 10

Game.Mixins.ConsumesMemory =
  listeners:
    checkMemory:
      priority: 50
      # Dict should be an object with a key of usedMemory
      func: (type, dict) ->
        totalMemory = dict.usedMemory || 0
        dict.usedMemory = totalMemory + @_consumedMemory

  init: (template) ->
    # How much MEM does this ability take. Default 1.
    @_consumedMemory = template.memory || 1

Game.Mixins.PlayerPickup =
  name: "PlayerPickup"
  groupName: "Pickup"
  listeners:
    pickup:
      priority: 15
      func: (type, dict) ->
        item = dict.item
        if @addToInventory(item)
          @getMap().removeEntity(item)

        console.log(@inventorySlotsOpen())

# These are items that take effect immediately when the actors walk over them.
Game.Mixins.WalkoverEffectItem =
  name: "WalkoverEffectItem"
  groupName: "Item"
  listeners:
    onWalkedOn:
      priority: 50
      func: (type, dict) ->
        actor = dict.source
        @_useEffect(actor, @)

  init: (template) ->
    @_useEffect = template.useEffect || (actor) -> return


# These are items that picked up when the actors walk over them.
Game.Mixins.WalkoverPickupItem =
  name: "WalkoverPickupItem"
  groupName: "Item"
  listeners:
    onWalkedOn:
      priority: 50
      func: (type, dict) ->
        actor = dict.source
        actor.raiseEvent('pickup', {item: @})

  init: (template) ->
    @_useEffect = template.useEffect || (actor) -> return
