Game =
  _display: null
  _currentScreen: null
  _screenHeight: 31
  _screenWidth: 80
  _messageHeight: 6
  _statusHeight: 1
  init: ->
    # initialize the things
    @_display = new ROT.Display
      width: @_screenWidth
      height: @_screenHeight

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
    @_screenWidth

  getHeight: ->
    @_screenHeight - @_messageHeight - @_statusHeight

  getMessageHeight: ->
    @_messageHeight

  getStatusHeight: ->
    @_statusHeight

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
