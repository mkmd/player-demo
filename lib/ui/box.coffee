class Box extends hLab.ui.Widget

  top = () ->
    position = @$.as.number @container.css 'z-index'
    for layer in @.layers() #cache top layer (z-index)
      layer = @dom layer
      pos = @$.as.number layer.css 'z-index'
      if pos > position
        position = pos
    position

  upsert = (name, css=null) ->
    layer = get.call @, name
    if not layer.length
      css ?= {}
      newLayer = @dom("<div data-name=\"#{name}\" class=\"#{name}\" />").css position: 'absolute'
      css.zIndex = (top.call @) + 1
      newLayer.css css
      @container.append newLayer
      layer = newLayer
    else if css
      delete css['zIndex']
      layer.css css
    layer

  remove = (name) ->
    get.call(@, name).remove()

  get = (layer) -> #name
    name = if @$.is.object layer then layer.attr 'data-name' else layer #instanceof Object
    return layer unless name
    @container.children "*[data-name=\"#{name}\"]"

  move = (name, position, direction=1) -> #direction
    layer = get.call @, name
    return if not layer

    oldPosition = @$.as.number layer.css 'z-index'
    position = @$.as.number position
    position = oldPosition + direction if not position
    return if not @$.is.number position or position is oldPosition

    layer.css {zIndex: position}

    for layer in @container.children("*[data-name!=\"#{name}\"]")
      layer = @dom layer
      pos = @$.as.number layer.css 'z-index'
      if oldPosition*direction <= pos*direction <= position*direction
        layer.css {zIndex: pos-direction}

  constructor: (options=null) ->
    super()

    options ?= {css: {}}
    options.css ?= {}
    options.css.zIndex ?= 9000
    options.css.position = 'absolute'

    @container = @dom "<div id=\"box[#{@id}]\" class=\"box\" />"
    @container.css options.css
    @target = options.target

  layer: (name, css=null) ->
    upsert.call @, name, css

  aslayer: (element, name) ->
    element = @dom element
    return unless (element.parents @container[0]).length
    element.attr 'data-name', name
    element.addClass name unless element.hasClass name

    element.css position: 'absolute', 'z-index': (top.call @) + 1
    element

  layers: (exclude=null) ->
    pat = if exclude then "*[data-name!=#{exclude}]" else '*[data-name]'
    @container.find pat

  has: (layer, nested=null) ->
    return (@container.has "*[data-name=\"#{layer}\"]").length > 0 if not nested
    @dom.contains (get.call @, layer)[0], nested[0]

  unlayer: (src) ->
    if @$.is.string src
      remove.call @, src
    else if @$.is.array src
      layer.remove() for layer in src
    else
      src.remove()
    @

  rename: (from, to) ->
    from_layer = (get.call @, from)
    to_layer = (get.call @, to)

    (from_layer.attr 'data-name', to).removeClass().addClass to

    if to_layer.length
      from_layer.css 'z-index': to_layer.css 'z-index'
      to_layer.remove()
    @

  clear: () ->
    self = @
    @.layers().each ->
      self.dom(@).remove()
    @

  up: (name, relativeTo=null) ->
    move.call @, name, (get.call @, relativeTo).css 'z-index'
    @

  down: (name, relativeTo=null) ->
    move.call @, name, ((get.call @, relativeTo).css 'z-index'), -1
    @

  swap: (a, b) ->
    a = get.call @, a
    b = get.call @, b
    if a.length and b.length
      position = @$.as.number a.css 'z-index'
      a.css {zIndex: @$.as.number b.css 'z-index'}
      b.css {zIndex: position}
    @

  show: (layer, options=null) ->
    (get.call @, layer).show options
    @

  hide: (layer, options=null) ->
    (get.call @, layer).hide options
    @

  extras: () ->
    return @container.children '*:not(.video)'

  fitTo: (to, only=null) ->
    src = get.call @, to
    return unless src.length

    size = width: src.outerWidth(), height: src.outerHeight() # width(), height()
    layers = if only then @container.children("*[data-name=\"#{only}\"]") else @container.children("*[data-name!=\"#{to}\"]")

    (@dom layer).css size for layer in layers
    @

  setup: (to=null) ->
    @dom(to ? @target).append @container
    @

  cleanup: () ->
    @container.remove()
    @

  # deprecated
  paint: (layer, content) ->
    (get.call @, layer).append content
    @


hLab.use 'ui', Box: Box