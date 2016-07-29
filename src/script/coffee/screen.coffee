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
    map.push(Game.Tile.nullTile for y in [0..(@_mapHeight - 1)]) for num in [0..(@_mapWidth - 1)]
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
    screenWidth = Game.getWidth()
    screenHeight = Game.getHeight()
    # Make sure the x-axis doesn't go to the left of the left bound
    topLeftX = Math.max(0, @_player.getX() - (screenWidth / 2));

    # Make sure we still have enough space to fit an entire game screen
    topLeftX = Math.min(topLeftX, @_map.getWidth() - screenWidth);

    # Make sure the y-axis doesn't above the top bound
    topLeftY = Math.max(0, @_player.getY() - (screenHeight / 2));

    # Make sure we still have enough space to fit an entire game screen
    topLeftY = Math.min(topLeftY, @_map.getHeight() - screenHeight);

    # Render the map to the display
    for x in [topLeftX..(topLeftX + screenWidth)]
      for y in [topLeftY..(topLeftY + screenHeight)]
        glyph = @_map.getTile(x,y)
        display.draw(x - topLeftX, y - topLeftY, glyph.getChar(),
          glyph.getForeground(), glyph.getBackground())

    player = null

    for entity in @_map.getEntities()
      pos = entity.getXY()
      if (pos.x >= topLeftX && pos.x < (topLeftX + screenWidth) &&
          pos.y >= topLeftY && pos.y < (topLeftY + screenHeight))

        if entity.hasMixin("PlayerActor")
          player = entity
        else
          display.draw(pos.x - topLeftX, pos.y - topLeftY, entity.getChar(),
            entity.getForeground(), entity.getBackground())

    # Draw the player last
    pos = player.getXY()
    display.draw(pos.x - topLeftX, pos.y - topLeftY, player.getChar(),
      player.getForeground(), player.getBackground())

    # Draw status
    stats = '%c{white}%b{black}'
    stats += vsprintf('HP: %d/%d', [@_player.getHp(), @_player.getMaxHp()])
    stats += vsprintf(' Atk: %d Def: %d', [@_player.getAttack(),
      @_player.getDef()])
    display.drawText(0, screenHeight + 1, stats)

    # Draw messages
    messageY = screenHeight + 2
    for message in @_player.getMessages()
      messageY += display.drawText(
        0, messageY, '%c{white}%b{black}' + message
      )

  move: (cx, cy) ->
    # X
    dX = @_player.getX() + cx

    # Y
    dY = @_player.getY() + cy

    @_player.tryMove(dX, dY, @_map)

  handleInput: (eventType, event) ->
    if @_subscreen != null
      @_subscreen.handleInput(eventType, event)
      return
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
          @move(-1, 0)
        when ROT.VK_RIGHT
          @move(1, 0)
        when ROT.VK_UP
          @move(0, -1);
        when ROT.VK_DOWN
          @move(0, 1);
        # Inventory
        when ROT.VK_I
          if (item for letter, item of @_player.getItems()).filter((x) -> return x).length == 0
            # If the player has no items, send a message and don't take a turn
            Game.sendMessage(@_player, "You are not carrying anything!");
            Game.refresh();
          else
            # Show the inventory
            Game.Screen.InventoryScreen.setup(@_player, @_player.getItems());
            @setSubScreen(Game.Screen.InventoryScreen);
          return;
      @_map.getEngine().unlock()

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
