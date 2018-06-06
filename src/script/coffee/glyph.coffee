class Glyph
  constructor: (options) ->
    options = options or {}
    @_char = options.symbol or ' '
    @_foreground = options.foreground || 'white'
    @_background = options.background || '#002200'

  getChar: ->
    @_char

  getForeground: ->
    @_foreground

  getBackground: ->
    @_background

Game.Glyph = Glyph
