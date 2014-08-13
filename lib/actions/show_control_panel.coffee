
class ShowControlPanel extends hLab.actions.Action

  constructor: (options=null) ->
    super()
    @[name] = option for name, option of options if options

  run: (args) ->
    return if @persist and @panel # singleton

    # get the managed movie
    @movie = @context.scenario.movies[@movie] if @$.is.number @movie
    @movie = @context.player.movie unless @movie
    return unless @movie

    rectangle = @context.player.movie.actor or @context.player.movie.size

    @panel = new @$.ui.ControlPanel
      layer: @layer
      canvas: @context.canvas
      rectangle: rectangle
      view: @view
      logotype: @logotype
      css: @css

    unless @persist
      @context.scenario.once @id + ':select', => @.cleanup yes
      @context.player.once @id + ':cleanup', => @.cleanup yes #on

    @context.player.on @id + ':meta', =>
      @context.canvas.fitTo 'video', @layer if @layer

      state = @panel.state()
      if state.mute
        @context.player.mute()
      else if state.volume
        @context.player.volume state.volume

    @context.player.on @id + ':change.done', =>
      return unless @panel
      @panel.resize @context.player.movie.actor or @context.player.movie.size

    @movie.on @id + ':timeupdate', =>
      @panel.safeSeek (@movie.time * 100) / @movie.duration

    @movie.on @id + ':play', =>
      @panel.playing yes

    @movie.on @id + ':pause', =>
      @panel.playing no

    @movie.on @id + ':mute', =>
      @panel.mute yes

    @movie.on @id + ':unmute', =>
      @panel.mute no

    @panel.setup()

    # set init state of panel
    @panel.playing @movie.is.playing
    @panel.mute @movie.is.muted
    @panel.volume @movie.volume

    @panel.once 'close', () =>
      @.cleanup yes
      @context.cleanup()

    @panel.on 'play', =>
      return unless @movie
      if @movie.id isnt @context.player.movie.id
        @context.scenario.select @movie

      @movie.play()

    @panel.on 'pause', =>
      return unless @movie
      @movie.pause?()

    @panel.on 'mute', =>
      return unless @movie
      @movie.mute?()

    @panel.on 'unmute', =>
      return unless @movie
      @movie.unmute?()

    @panel.on 'volume', (percents) =>
      return unless @movie or @movie.id isnt @context.player.movie.id
      @context.player.volume percents

    @panel.on 'seek.done', (percents) =>
      @context.player.seek percents

    @

  cleanup: (force=no) ->
    unless @persist
      @movie.off @id + ':*'
      @context.scenario.off @id + ':*'
      @context.player.off @id + ':*'

    return unless @panel and force

    @panel.cleanup()
    @panel = null

    @context.canvas.unlayer @layer if @layer
    @

hLab.use 'actions', ShowControlPanel: ShowControlPanel
