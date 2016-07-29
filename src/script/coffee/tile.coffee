class Tile extends Glyph
  constructor: (options) ->
    options = options or {}
    super(options)
    @_isWalkable = options.isWalkable || false
    @_isDiggable = options.isDiggable || false

  isWalkable: ->
    @_isWalkable

  isDiggable: ->
    @_isDiggable


Game.Tile = Tile

# Set some standard tiles
Game.Tile.nullTile = new Game.Tile({})

Game.Tile.wallTile = new Game.Tile({
  symbol: '#',
  foreground: 'goldenrod',
  isDiggable: true,
})

Game.Tile.floorTile = new Game.Tile({
  symbol: '.',
  isWalkable: true,
})
