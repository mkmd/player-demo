
class Speaker extends hLab.lib.Emitter

  unlinkCSS = ->
    (@dom "link[data-hlp=\"hlp[#{@id}]\"]").remove()

  @dom: (engine) ->
    @::dom = engine
    hLab.ui.Widget.dom engine
    @

  constructor: (options) ->
    super()

    @cleanOnEmpty = yes

    @terminated = no

    @stylesheet = options.css
    @projectId = options.projectId
    @root = options.root

    @settings = options.settings

    stages = if @$.platform.mobile then options.mobile else options.stages
    @.stagelist stages if stages

    handleEvent = (listener) ->
      action = @settings.action listener
      action.bind @
      action.run() unless @terminated

    for event, eventOpt of options.on
      listeners = []
      if @$.is.array eventOpt then Array::push.apply listeners, eventOpt else listeners.push eventOpt
      @.on event, handleEvent.bind @, listener for listener in listeners

  autocleanup: (enable=yes) ->
    @cleanOnEmpty = enable
    @

  css: (url) ->
    return unless url

    rel = 'stylesheet'
    if (url.split '.').pop() is 'less'
      rel += '/less'
      url += "?#{Date.now()}"

    opts =
      href: url
      type: 'text/css'
      rel: rel
      'data-hlp': "hlp[#{@id}]"

    unlinkCSS.call @
    (@dom '<link/>', opts).prependTo 'head'
    @

  signature: () ->
    return 'Speaker'

  stagelist: (stages) ->
    @stages = {}
    for name in stages
      @stages[name] = @settings.stage name
      continue unless @stages[name]
      @stages[name].name = name

      if @$.platform.mobile
        p = @stages[name].player.priority
        if 'canvas' in p
          p.splice (p.indexOf 'canvas'), 1
          @stages[name].player.priority = p

      if @cleanOnEmpty
        @stages[name].once 'cleanup', (stage) =>
          for name, obj of @stages when obj is stage
            delete @stages[name]
            break

          if @cleanOnEmpty
            unless (@$.object.keys @stages).length
              setTimeout =>
                @.cleanup()
              , 100

        # deffering stage cleanup (f.e. analytics extension must "seeing" the stages, after processing analytics do full cleanup)
        # right way: don't subscribing to app cleanup action, extensions must subscribes to stage cleanup
        # extenstions should not assume the existence of stages on application cleanup

    @

  setup: () ->
    @.createRoot()

    @.emit 'setup'

    return unless @stages
    @.css @stylesheet

    for name, stage of @stages
      @createStageContainer stage
      stage.setup()

    @.emit 'setup.done'
    @

  createRoot: () ->
    return if @root and @root[0] instanceof Element
    if @root
      @root = (@dom '<div id="' + @root + '" />').appendTo 'body'
    else
      @root = @dom 'body'
    @

  createStageContainer: (stage) ->
    return if (@dom stage.canvas.target).length
    (@dom '<div id="' + stage.canvas.target[1..] + '" />').appendTo @root
    @

  cleanup: () ->
    unlinkCSS.call @

    if @$.is.object @root
      @root.remove() if @root and @root[0] isnt ($ 'body')[0]
      @root = null

    @.emit 'cleanup'

    @cleanOnEmpty = no
    @.clear()

    @.off()

    @terminated = yes

    @.emit 'cleanup.done'
    @

  clear: () ->
    return unless @stages
    for name, stage of @stages
      stage.cleanup()
    @stages = null
    @

hLab.use 'apps', Speaker: Speaker