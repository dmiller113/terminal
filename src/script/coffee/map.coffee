class Map
  constructor: (tiles, player) ->
    # Entity list
    @_entities = []

    # Scheduler stuff
    @_scheduler = new ROT.Scheduler.Simple()
    @_engine = new ROT.Engine(@_scheduler)

    # Tile stuff
    @_tiles = tiles

    # Grab our width and height from the passed array.
    @_width = tiles.length
    @_height = tiles[0].length

    @_memory = []
    # Ugly list comprehenions
    @_memory.push(false for y in [0...@_height]) for x in [0...@_width]


    # FoV
    map = this
    blocksLight = (x, y) ->
      !(map.getTile(x, y).blocksLight())

    @_fov = new ROT.FOV.DiscreteShadowcasting(blocksLight, {topology: 4})

    # Add the player
    if typeof player != undefined
      @addEntityAtRandomPosition(player)

    # Add some actors
    for t in [0..415]
      @addEntityAtRandomPosition(Game.EntityRepository.createRandom())
    for t in [0..10]
      @addEntityAtRandomPosition(Game.ItemRepository.createRandom())

  # Getters
  getWidth: ->
    @_width

  getHeight: ->
    @_height

  # Get a specific tile
  getTile: (x, y) ->
    # Return null tile if x, y is out of bounds, otherwise return tile.
    if x >= 0 and x < @_width and y >= 0 and y < @_height
      @_tiles[x][y] || Game.Tile.nullTile
    else
      Game.Tile.nullTile

  getRandomFloorTile: () ->
    loop
      rX = Math.floor(ROT.RNG.getUniform() * @_width)
      rY = Math.floor(ROT.RNG.getUniform() * @_height)
      break if @isEmptyFloor(rX, rY)
    {
      x: rX, y: rY,
    }

  getEngine: () ->
    @_engine

  getEntities: () ->
    @_entities

  getEntityAt: (x, y) ->
    for entity in @_entities
      position = entity.getXY()

      if position.x == x and position.y == y
        return entity

    return false

  getEntitiesWithinRadius: (centerX, centerY, radius) ->
    results = []
    leftX = centerX - radius
    rightX = centerX + radius
    topY = centerY - radius
    bottomY = centerY + radius

    for entity in @_entities
      [x, y] = entity.getXY()
      if x <= rightX and x >= leftX and y >= topY y <= bottomY
        results.push(entity)

    # Return results
    results

  getFoV: () -> @_fov

  isEmptyFloor: (x, y) ->
    @getTile(x, y) == Game.Tile.floorTile and !@getEntityAt(x, y)

  isRemembered: (x, y) ->
    @_memory[x][y]

  remember: (x, y) ->
    @_memory[x][y] = true

  forget: (x, y) ->
    @_memory[x][y] = false

  addEntity: (entity) ->
    pos = entity.getXY()

    # Check for sane position
    if pos.x < 0 || pos.y < 0 || pos.x >= @_width || pos.y >= @_height
      throw new Error('Adding entity out of bounds')

    # Set the map on the entity
    entity.setMap(@)

    # Add the entity to the map's list
    @_entities.push(entity)

    # If we've got an actor, put them in the Scheduler
    if entity.hasMixin("Actor")
      @_scheduler.add(entity, true)

  addEntityAtRandomPosition: (entity) ->
    pos = @getRandomFloorTile()
    entity.setX(pos.x)
    entity.setY(pos.y)
    @addEntity(entity)

  removeEntity: (entity) ->
    for i in [0..@_entities.length-1]
      if @_entities[i] == entity
        @_entities.splice(i, 1)
        break

    if entity.hasMixin("Actor")
      @_scheduler.remove(entity)

  dig: (x, y) ->
    # Check to see if we can dig the passed location
    tile = @getTile(x, y)
    if tile.isDiggable()
      @_tiles[x][y] = Game.Tile.floorTile

Game.Map = Map
