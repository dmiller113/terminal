Game.Screen = {}
# Screen interface is:
# enter: function(). Called when a screen is first swapped to.
# exit: function(). Called when a screen is swapped from.
# render: function(display). Called to render the screen onto the passed
#   display.
# handleInput(eventType, event): Called to handle various input events.

Game.Screen.startScreen =
  enter: ->
    console.log("we in dere")
  exit: ->
    console.log("we out of dere")
  render: (display) ->
    # Render the prompt to the screen
    display.drawText(1,1, "%c{yellow}Terminal")
    display.drawText(1,2, "%c{gray}Press [Enter] to Start")
  handleInput: (eventType, event) ->
    # if [Enter] is pressed, go to the play screen
    if eventType == "keydown" and event.keyCode == ROT.VK_RETURN
      Game.switchScreen(Game.Screen.playScreen)


Game.Screen.playScreen =
  _map: null
  _mapWidth: 240,
  _mapHeight: 72,
  _player: null,
  _subscreen: null,

  setSubScreen: (screen) ->
    @_subscreen = screen
    Game.refresh()

  enter: ->
    console.log("Entered Play Screen")
    # Set up map. Empty map to begin with.
    map = [];
    # Ugly list comprehenions
    map.push(Game.Tile.nullTile for y in [0...@_mapHeight]) for num in [0...@_mapWidth]
    # Set up map generator from ROT
    generator = new ROT.Map.Cellular(@_mapWidth, @_mapHeight)
    generator.randomize(0.5)
    # We're going to smooth the automita 3 times.
    totalIterations = 3
    generator.create() for num in [1..totalIterations]
    # Last one, we're keeping the results
    generator.create((x, y, value) ->
      if value == 1
        map[x][y] = Game.Tile.wallTile
      else
        map[x][y] = Game.Tile.floorTile
    )
    @_player = new Entity(Game.playerTemplate)
    @_map = new Game.Map(map, @_player)
    @_map.getEngine().start()

  exit: ->
    console.log("Exited Play Screen")

  render: (display) ->
    # render a subscreen of there is one
    if @_subscreen
      @_subscreen.render(display)
      return

    # Figure out where our top left cell should be
    screenWidth = Game.getScreenWidth()
    screenHeight = Game.getScreenHeight()
    mapInsetX = Game.getConstants()._screenMapCol
    mapInsetY = Game.getConstants()._screenMapRow
    constants = Game.getConstants()
    stats = {}
    @_player.raiseEvent("getStats", {stats: stats})

    # Make sure the x-axis doesn't go to the left of the left bound
    topLeftX = Math.max(0, @_player.getX() - (screenWidth / 2));

    # Make sure we still have enough space to fit an entire game screen
    topLeftX = Math.min(topLeftX, @_map.getWidth() - screenWidth);

    # Make sure the y-axis doesn't above the top bound
    topLeftY = Math.max(0, @_player.getY() - (screenHeight / 2));

    # Make sure we still have enough space to fit an entire game screen
    topLeftY = Math.min(topLeftY, @_map.getHeight() - screenHeight);

    @_renderTiles(display, constants, stats, {
      screenWidth: screenWidth, screenHeight: screenHeight,
      mapInsetX: mapInsetX, mapInsetY: mapInsetY,
      topLeftX: topLeftX, topLeftY: topLeftY,
    })


  move: (cx, cy) ->
    # X
    dX = @_player.getX() + cx

    # Y
    dY = @_player.getY() + cy
    @_player.raiseEvent("onMove")
    @_player.tryMove(dX, dY, @_map)

  handleInput: (eventType, event) ->
    if @_subscreen != null
      @_subscreen.handleInput(eventType, event)
      return
    newTurn = false
    x = @_player.getX()
    y = @_player.getY()
    offsets = @getOffsets(x, y)

    if eventType == "keydown"
      switch event.keyCode
        when ROT.VK_RETURN
          Game.switchScreen(Game.Screen.winScreen)
        when ROT.VK_ESCAPE
          Game.switchScreen(Game.Screen.loseScreen)
        when ROT.VK_R
          Game.switchScreen(Game.Screen.playScreen)
        # Movement
        when ROT.VK_LEFT
          newTurn = @move(-1, 0)
        when ROT.VK_RIGHT
          newTurn = @move(1, 0)
        when ROT.VK_UP
          newTurn = @move(0, -1)
        when ROT.VK_DOWN
          newTurn = @move(0, 1)
    else if eventType == "keypress"
      switch event.keyCode
        when ROT.VK_SEMICOLON
          Game.Screen.lookScreen.setup(@_player,
            x, y, offsets.x, offsets.y)
          @setSubScreen(Game.Screen.lookScreen)
    dict = {event: event, actor: @_player, eventType: eventType, offsets: offsets}
    @_player.raiseEvent("keyEvent", dict)
    if "newTurn" of dict
      newTurn = dict.newTurn
    if newTurn
      @_map.getEngine().unlock()

  _drawUILines: (display, constants, stats) ->
    # Draw UI lines
    for y in [0...Game.getHeight()]
      for x in [0...Game.getWidth()]
        char = ""
        # Corners
        if x == 0 and y == 0
          char = String.fromCharCode(0x2554)
        else if (x == 0 and y == Game.getHeight()-1)
          char = String.fromCharCode(0x255A)
        else if (x == Game.getWidth() - 1 and y == Game.getHeight() - 1)
          char = String.fromCharCode(0x255D)
        else if x == Game.getWidth() - 1 and y == 0
          char = String.fromCharCode(0x2557)
        # Intersections
        else if (x == constants._statusRow and y == 0 or
            x == 0 and y == constants._messageCol-1) or
            ((x == constants._statusRow or
              x == Game.getWidth() - 1) and (
             y == constants._networkCol - 1 or
             y == constants._analysisCol - 1 or
             y == constants._inViewCol - 1 or
             y == constants._messageCol - 1
            ))
          char = String.fromCharCode(0x23E3)
        # Horizontal Lines
        else if y == 0 or y == constants._messageCol - 1 or
          y == Game.getHeight() - 1 or (x > constants._statusRow and
                                       (y == constants._networkCol - 1 or
                                        y == constants._analysisCol - 1 or
                                        y == constants._inViewCol - 1))
          char = String.fromCharCode(0x2550)
        # Vertical Lines
        else if x == 0 or (x == constants._statusRow and y < constants._messageCol) or
                           x == Game.getWidth() - 1
          char = String.fromCharCode(0x2551)
        display.draw(x, y, char, "lime", "black")

    # Draw titles
    for prop, title of constants._titles
      display.drawText(title.x, title.y, "%c{lime}-" + title.title + "-%c{}")

  _fillUI: (display, constants, stats, inView, dimensions) ->
    screenWidth = dimensions.screenWidth
    screenHeight = dimensions.screenHeight
    # Draw Ability Markers
    activeMemory = {}
    @_player.raiseEvent("getAbilities", activeMemory)

    i = 0
    for ability, value of activeMemory.abilities
      display.drawText(constants._statusRow + 2, constants._abilityCol + i,
        "%c{lime}" + ability + ": #{value.name}%c{}")
      i++

    focus = {}
    @_player.raiseEvent("checkFocus", focus)

    # Draw HP values
    statsText = vsprintf('Structure: %d/%d', [@_player.getHp(), @_player.getMaxHp()])
    display.drawText(constants._statusRow + 2, constants._hpFocusCol, "%c{lime}" + statsText + "%c{}")
    display.drawText(constants._statusRow + 6, constants._hpFocusCol + 1,
      "%c{lime}Focus: #{focus.totalFocus || 0}% %c{}")

    # Player Name
    display.drawText(constants._statusRow + 2, constants._nameCol,
      "%c{lime}" + @_player.getName() + "%c{}")

    # Player Stats
    i = 0
    for stat, value of stats
      x = if i > 1 then constants._statusRow + 2 else constants._statusRow + 13
      display.drawText(x, constants._statCol + (i % 2),
        "%c{lime}" + stat + ": " + value + "%c{}")
      i++

    # In view
    # Draw the enemies in View
    i = 0
    sortFunction = (item1, item2) ->
      if item1 < item2
        return -1
      if item1 <= item2
        return 0
      return 1

    inViewKeys = Object.keys(inView).sort(sortFunction)

    # Contain list to 8 objects
    if inViewKeys.length > 8
      inViewKeys = inViewKeys[...8]
      display.drawText(constants._statusRow + 2, constants._inViewCol + 7,
        "And more...")

    for key in inViewKeys
      # Handle the seperation
      additionalCol = 2
      additionalRow = if i < 4 then i else i - 4
      if i > 3
        additionalCol += 4 + inViewKeys[i-4].length
      display.drawText(
        constants._statusRow + additionalCol, constants._inViewCol + additionalRow,
        "%c{#{inView[key].color}}" + inView[key].number + " " + key + "%c{}")
      i++
    # Nothing in view, add an empty message
    if inViewKeys.length == 0
      display.drawText(constants._statusRow + 2, constants._inViewCol,
        "%c{lime} Nothing in view...%c{}")

    # Draw messages
    messageY = screenHeight + 2
    for message in @_player.getMessages()
      messageY += display.drawText(
        1, messageY, '%c{lawngreen}%b{black}' + message
      )

  _renderTiles: (display, constants, stats, dimensions) ->
    # Dimensions
    topLeftX = dimensions.topLeftX
    topLeftY = dimensions.topLeftY
    screenHeight = dimensions.screenHeight
    screenWidth = dimensions.screenWidth
    mapInsetX = dimensions.mapInsetX
    mapInsetY = dimensions.mapInsetY

    # Compute FoV
    visibleFoV = {}

    callback = (x, y, radius, visibility) ->
      visibleFoV["#{x},#{y}"] = true

    @_player.getMap().getFoV().compute(@_player.getX(), @_player.getY(),
      @_player.getSightRadius(), callback)

    @_drawUILines(display, constants, stats)

    # Render the map to the display
    for x in [topLeftX..(topLeftX + screenWidth - 1)]
      for y in [topLeftY..(topLeftY + screenHeight - 1)]
        glyph = @_map.getTile(x,y)
        if visibleFoV["#{x},#{y}"]
          display.draw(mapInsetX + x - topLeftX,
                       mapInsetY + y - topLeftY,
                       glyph.getChar(), glyph.getForeground(),
                       glyph.getBackground())

          if @_map.isRemembered(x,y) == false
            @_map.remember(x,y)
        else
          if @_map.isRemembered(x,y)
            display.draw(mapInsetX + x - topLeftX,
                         mapInsetY + y - topLeftY,
                         glyph.getChar(),
                         "#3C3C3C", "black")
          else
            num = Math.floor(Math.random() * 4)
            block = 0x2590
            if num == 0
              block = 0x2588
            display.draw(
              mapInsetX + x - topLeftX, mapInsetY + y - topLeftY,
              String.fromCodePoint(block + num), "#131313", "black")

    player = null

    inView = {}
    # Render entities to the screen
    for entity in @_map.getEntities()
      pos = entity.getXY()
      if (pos.x >= topLeftX && pos.x < (topLeftX + screenWidth) &&
          pos.y >= topLeftY && pos.y < (topLeftY + screenHeight) &&
          visibleFoV["#{pos.x},#{pos.y}"])
        if entity.hasMixin("PlayerActor")
          player = entity
        else
          display.draw(
            mapInsetX + pos.x - topLeftX, mapInsetY + pos.y - topLeftY,
            entity.getChar(), entity.getForeground(), entity.getBackground())

          # Append to the list of actors in view of the player
          if entity.name of inView
            inView[entity.name].number += 1
          else
            inView[entity.name] = {
              number: 1
              symbol: entity.getChar()
              color: entity.getForeground()
            }

    # Draw the player last
    pos = player.getXY()
    display.draw(
      mapInsetX + pos.x - topLeftX, mapInsetY + pos.y - topLeftY,
      player.getChar(), player.getForeground(), player.getBackground())

    @_fillUI(display, constants, stats, inView, {screenWidth: screenWidth, screenHeight: screenHeight})

  getOffsets: (x, y) ->
    screenWidth = Game.getScreenWidth()
    screenHeight = Game.getScreenHeight()

    # Make sure the x-axis doesn't go to the left of the left bound
    topLeftX = Math.max(0, x - (screenWidth / 2));

    # Make sure we still have enough space to fit an entire game screen
    topLeftX = Math.min(topLeftX, @_map.getWidth() - screenWidth);

    # Make sure the y-axis doesn't above the top bound
    topLeftY = Math.max(0, y - (screenHeight / 2));

    # Make sure we still have enough space to fit an entire game screen
    topLeftY = Math.min(topLeftY, @_map.getHeight() - screenHeight);

    return {x: topLeftX, y: topLeftY}

Game.Screen.winScreen =
  enter: ->
    console.log("Entered winScreen")
  exit: ->
    console.log("Exiting winScreen")
  render: (display) ->
    display.drawText(1,1, "%c{green}Yay, you won.")
    display.drawText(1,2, "%c{gray}Press [Enter] to try again")
  handleInput: (eventType, event) ->
    if eventType == "keydown" and event.keyCode == ROT.VK_RETURN
      Game.switchScreen(Game.Screen.startScreen)

Game.Screen.loseScreen =
  enter: ->
    console.log("Entered loseScreen")
  exit: ->
    console.log("Exited loseScreen")
  render: (display) ->
    display.drawText(1,1, "%c{red}Buu, you lost.")
    display.drawText(1,2, "%c{gray}Press [Enter] to try again")
  handleInput: (eventType, event) ->
    if eventType == "keydown" and event.keyCode == ROT.VK_RETURN
      Game.switchScreen(Game.Screen.startScreen)

class ItemListScreen
  constructor: (template) ->
    @_caption = template.caption
    @_okFunction = template.ok
    @_canSelectInput = template.canSelect
    @_canSelectMultipleItems = template.canSelectMultipleItems

  setup: (player, items) ->
    @_player = player
    @_items = items
    @_selectedIndices = {}

  render: (display) ->
    letters = 'abcdefghijklmnopqrstuvwxyz'

    display.drawText(0, 0, @_caption)
    row = 0
    for letter, item of @_items
      if item
        display.drawText(0, row + 2, letter + ' - ' + item.describeA(true))
      row += 1

  executeOkFunction: () ->
    selectedItems = {}
    for key, _ of @_selectedIndices
      selectedItems[key] = @_items[key]
    Game.Screen.playScreen.setSubscreen(null)
    if @executeOkFunction(selectedItems)
      @_player.getMap().getEngine().unlock()

  handleInput: (eventType, event) ->
    if eventType == 'keydown'
      # If the user hit escape, hit enter and can't select an item, or hit
      # enter without any items selected, simply cancel out
      if (event.keyCode == ROT.VK_ESCAPE or
        (event.keyCode == ROT.VK_RETURN and
          (!@_canSelectItem or Object.keys(@_selectedIndices).length == 0)))
        Game.Screen.playScreen.setSubScreen(null)
      # Handle pressing return when items are selected
      else if event.keyCode == ROT.VK_RETURN
        @executeOkFunction()
      # Handle pressing a letter if we can select
      else if (@_canSelectItem and event.keyCode >= ROT.VK_A and
          event.keyCode <= ROT.VK_Z)
        # Check if it maps to a valid item by subtracting 'a' from the character
        # to know what letter of the alphabet we used.
        index = event.keyCode - ROT.VK_A
        if @_items[index]
          # If multiple selection is allowed, toggle the selection status, else
          # select the item and exit the screen
          if @_canSelectMultipleItems
            if @_selectedIndices[index]
                delete @_selectedIndices[index]
            else
                @_selectedIndices[index] = true
            # Redraw screen
            Game.refresh()
          else
            @_selectedIndices[index] = true
            @executeOkFunction()

Game.Screen.InventoryScreen = new ItemListScreen({
  caption: "Inventory",
  canSelect: false,
})


class TargetBasedScreen
  constructor: (template) ->
    template = template || {}
    constants = Game.getConstants()

    # Grab the function that executes on selection, or a default function that
    # does nothing and consumes no turn.
    @_selectFunction = template.okFunction || (x, y, map, actor) ->
      return false

    # The function that sets the caption, or a function that returns the empty
    # string
    @_captionFunction = template.captionFunction || (x, y, map) ->
      return ""

    @_isLineConnected = template.isLineConnected || false

    # The function that draws the cursor or a default *
    @_cursorFunction = template.cursorFunction || (display, x, y, isConnected) ->

      display.draw(x + @_mapInsetX, y + @_mapInsetY, '*', "#880088", "#000")

      if isConnected
        points = Game.Geometry.getLine(@_startX, @_startY, @_cursorX, @_cursorY)
        for point in points
          display.draw(point.x + @_mapInsetX, point.y + @_mapInsetY, '*',
            "#880088", "#000")

  setup: (player, startX, startY, offsetX, offsetY) ->
    @_player = player
    @_startX = startX - offsetX
    @_startY = startY - offsetY
    @_cursorX = @_startX
    @_cursorY = @_startY
    @_offsetX = offsetX
    @_offsetY = offsetY
    @_cachedStats = {}
    @_player.raiseEvent("getStats", {stats: @_cachedStats})
    @_constants = Game.getConstants()
    @_screenWidth = Game.getScreenWidth()
    @_screenHeight = Game.getScreenHeight()
    @_mapInsetX = Game.getConstants()._screenMapCol
    @_mapInsetY = Game.getConstants()._screenMapRow
    # Figure out where our top left cell should be
    @_map = @_player.getMap()
    # Make sure the x-axis doesn't go to the left of the left bound
    topLeftX = Math.max(0, startX - (@_screenWidth / 2));

    # Make sure we still have enough space to fit an entire game screen
    @_topLeftX = Math.min(topLeftX, @_map.getWidth() - @_screenWidth);

    # Make sure the y-axis doesn't above the top bound
    topLeftY = Math.max(0, startY - (@_screenHeight / 2));

    # Make sure we still have enough space to fit an entire game screen
    @_topLeftY = Math.min(topLeftY, @_map.getHeight() - @_screenHeight);

    visibleCells = {}
    callback = (x, y, radius, visibility) ->
      visibleCells["#{x},#{y}"] = true

    @_map.getFoV().compute(player.getX(), player.getY(),
      player.getSightRadius(), callback)

    @_visibleCells = visibleCells

  render: (display) ->
    Game.Screen.playScreen._renderTiles.call(Game.Screen.playScreen, display,
      @_constants, @_cachedStats, {
        screenWidth: @_screenWidth, screenHeight: @_screenHeight,
        mapInsetX: @_mapInsetX, mapInsetY: @_mapInsetY,
        topLeftX: @_topLeftX, topLeftY: @_topLeftY,
      })

    # Draw Caption
    @_captionFunction(@_cursorX + @_offsetX, @_cursorY + @_offsetY, @_map, display)

    # Draw cursor
    @_cursorFunction(display, @_cursorX , @_cursorY, @_isLineConnected, display)

  moveCursor: (dx, dy) ->
    @_cursorX = Math.max(0, Math.min(@_cursorX + dx, @_screenWidth - 1))
    @_cursorY = Math.max(0, Math.min(@_cursorY + dy, @_screenHeight - 1))

  executeOkFunction: () ->
    Game.Screen.playScreen.setSubScreen(null)
    if @_selectFunction(@_cursorX + @_offsetX, @_cursorY + @_offsetY,
        @_map, @_player)
      @_map.getEngine().unlock()

  handleInput: (inputType, inputData) ->
    # Move the cursor
    if inputType == 'keydown'
      switch inputData.keyCode
        when ROT.VK_LEFT
            @moveCursor(-1, 0)
        when ROT.VK_RIGHT
            @moveCursor(1, 0)
        when ROT.VK_UP
            @moveCursor(0, -1)
        when ROT.VK_DOWN
            @moveCursor(0, 1)
        when ROT.VK_ESCAPE
            Game.Screen.playScreen.setSubScreen(null)
        when ROT.VK_RETURN
          @executeOkFunction()
    Game.refresh();

  setSelectFunction: (func) ->
    @_selectFunction = func

Game.Screen.Functions = {}
Game.Screen.Functions.simpleCaption = (x, y, map, display) ->
  name = ""
  if @_map.isRemembered(x,y)
    name = map.getTile(x, y).name()
    if @_visibleCells["#{x},#{y}"]
      entity = map.getEntityAt(x, y)
      if entity
        name = entity.name
  else
    name = "Memory out of Scan range"
  constants = Game.getConstants()
  display.drawText(constants._captionCol, constants._captionRow,
    "%c{lime}Use the arrows to move, Escape to cancel, and Enter to view details.")
  display.drawText(constants._captionCol, constants._captionRow-1,
    "%c{lime}" + name + "%c{}")

Game.Screen.lookScreen = new TargetBasedScreen({
  captionFunction: Game.Screen.Functions.simpleCaption
})

Game.Screen.targetEntityScreen = new TargetBasedScreen({
  captionFunction: Game.Screen.Functions.simpleCaption
})
