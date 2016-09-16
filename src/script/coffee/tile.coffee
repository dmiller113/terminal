class Tile extends Glyph
  constructor: (options) ->
    options = options or {}
    super(options)
    @_isWalkable = options.isWalkable || false
    @_isDiggable = options.isDiggable || false
    @_blocksLight = options.blocksLight || false
    @_name = options.name || "Unknown Memory"

  isWalkable: ->
    @_isWalkable

  isDiggable: ->
    @_isDiggable

  blocksLight: ->
    @_blocksLight

  name: ->
    @_name

Game.Tile = Tile

# Set some standard tiles
Game.Tile.nullTile = new Game.Tile({})

Game.Tile.wallTile = new Game.Tile({
  symbol: '#',
  foreground: 'goldenrod',
  isDiggable: true,
  blocksLight: true,
  name: "Occupied Memory",
})

Game.Tile.floorTile = new Game.Tile({
  symbol: '.',
  isWalkable: true,
  name: "Free Memory",
})
