# A movable entity. Technically this also allows digging, so fix later.
Game.Mixins.Movable = {
  name: "Movable",
  groupName: "Movable",

  tryMove: (x, y, map) ->
    tile = map.getTile(x, y)
    target = map.getEntityAt(x, y)

    if target and target.hasMixin("Destructible")
      stats = {}
      @raiseEvent("getStats", {stats: stats})
      @raiseEvent("useContact", {target: target, stats: stats})
      return true
    else if target._blocksMovement
      return false
    else if tile.isWalkable()
      if target
        target.raiseEvent("onWalkedOn", {source: @})
      @_x = x
      @_y = y
      return true
    else if tile.isDiggable()
      map.dig(x, y)
      return true
    else
      return false
}
