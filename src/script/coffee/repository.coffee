class Repository
  constructor: (name, ctor) ->
    @_ctor = ctor
    @_name = name
    @_templates = {}
    @_randomable = {}

  define: (name, template) ->
    if typeof name == "object"
      template = name
      name = template.name.toLowerCase()
    @_templates[name] = template
    if (template.randomable || true)
      @_randomable[name] = template

  create: (name) ->
    if name of @_templates
      return new @_ctor(@_templates[name])

    throw new Error("No template named '" + name + "' in repository '" +
      @_name + "'.")

  createRandom: () ->
    return @create(Object.keys(@_randomable).random())
