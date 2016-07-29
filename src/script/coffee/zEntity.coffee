class Entity extends Glyph
  constructor: (options) ->
    # House Keeping
    options = options || {}
    super(options)

    # Grab our properties
    @name = options.name || ""
    @_x = options.x || 0
    @_y = options.y || 0
    @_map = options.map || null

    # Handle Mixins
    @_attachedMixins = {}
    @_attachedMixinGroups = {}

    mixins = options.mixins || []

    for mixin in mixins
      # Add the mixin to the attached mixin object
      @_attachedMixins[mixin.name] = true

      # If the mixin is part of a group, note that we have that group
      if "groupName" of mixin
        @_attachedMixinGroups[mixin.groupName] = true

      # Add the properties of the mixin to this entity.
      for key, value of mixin when (key != "name" && key != "init" && !@hasOwnProperty(key))
        @[key] = value

      if "init" of mixin
        mixin.init.call(this, options)

  describe: () ->
    return @name

  describeA: (isCapitalized) ->
    prefixes = if isCapitalized then ['A', 'An'] else ['a', 'an']
    name = @describe()
    prefix = prefixes[if name[0].toLowerCase() in 'aeiou' then 1 else 0]
    return prefix + ' ' + name

  setName: (name) ->
    @_name = name || ''

  setX: (x) ->
    @_x = x || 0

  setY: (y) ->
    @_y = y || 0

  setXY: (x, y) ->
    if typeof x == "object"
      @setX(x.x)
      @setY(x.y)
    else
      @setX(x)
      @setY(y)

  setMap: (map) ->
    @_map = map

  getName: () ->
    @_name

  getX: () ->
    @_x

  getY: () ->
    @_y

  getXY: () ->
    {
      x: @_x,
      y: @_y,
    }

  getMap: () ->
    @_map

  # Can pass either the mixin itself or its name
  hasMixin: (obj) ->
    if typeof obj == "object"
      @_attachedMixins[obj.name] || false
    else if typeof obj == "string"
      @_attachedMixins[obj] || @_attachedMixinGroups[obj] || false
    else
      false
