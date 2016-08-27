Version = 0.01
Game =
  _display: null
  _currentScreen: null
  _constants:
    _screenHeight: 34
    _screenWidth: 82
    _messageHeight: 5
    _statusHeight: 16
    _statusRow: 51
    _locationHeight: 2
    _analysisHeight: 1
    _inViewHeight: 4
    _nameCol: 1
    _statCol: 4
    _hpFocusCol: 7
    _abilityCol: 10
    _networkCol: 18
    _nodeCol: 19
    _analysisCol: 21
    _inViewCol: 23
    _messageCol: 28
    _screenMapCol: 1
    _screenMapRow: 1
    _screenMapHeight: 26
    _screenMapWidth: 50
    _statusTitleCol: 61
    _messageTitleCol: 37
    _titles:
      game:
        title: "Terminal [#{Version}]"
        x: 2
        y: 0
      messages:
        title: 'Messages'
        x: 2
        y: 27
      location:
        title: 'Location'
        x: 53
        y: 17
      inView:
        title: 'In View'
        x: 53
        y: 22
      analysis:
        title: 'Analysis'
        x: 53
        y: 20

  init: ->
    # initialize the things
    @_display = new ROT.Display
      width: @getWidth()
      height: @getHeight()

    # don't lose this.
    game = @

    # Helper function to bind events to the current screen.
    bindEventToScreen = (event) ->
      window.addEventListener(event, (e) ->
        # If we have a screen, send the event type and event to its
        # input handling function.
        if game._currentScreen != null
          game._currentScreen.handleInput(event, e)
      )

    bindEventToScreen("keydown")
    # bindEventToScreen("keyup")
    # bindEventToScreen("keypress")

  getDisplay: ->
    @_display

  getWidth: ->
    @_constants._screenWidth

  getHeight: ->
    (@_constants._screenHeight)

  getScreenWidth: ->
    @_constants._screenMapWidth

  getScreenHeight: ->
    @_constants._screenMapHeight

  getMessageHeight: ->
    @_constants._messageHeight

  getStatusHeight: ->
    @_constants._statusHeight

  getConstants: ->
    @_constants

  refresh: () ->
    if @_display != null and @_currentScreen != null
      @_display.clear()
      @_currentScreen.render(@_display)

  switchScreen: (screen) ->
    # If there was a previous screen, notify it that we're exiting it
    if @_currentScreen != null
      @_currentScreen.exit()
    # Set our current screen
    @_currentScreen = screen
    # If we're not swapping to a null/undefined screen, call its enter function
    # and display it.
    if @_currentScreen != null
      @_currentScreen.enter()
      @refresh()

window.onload = (event) ->
    # initialize the page
    if !ROT.isSupported()
      alert("Rot is not Supported")
    else
      Game.init()
      document.body.appendChild(Game.getDisplay().getContainer())
      Game.switchScreen(Game.Screen.startScreen)
