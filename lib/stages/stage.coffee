class Stage extends hLab.lib.Emitter

  constructor: (options) ->
    super()

    @autofit = yes

    @options = options
    @settings = options.settings

    # инициализация делегатов и применение ключевых свойств
    @canvas = @settings.canvas @options.canvas
    @player = @settings.player @options.player, nocache: yes
    @.use @options.scenario if @options.scenario
    @.movielist @options.movies if @options.movies

  # for IE < 9 message: not supported (html5 abilities is needed) (f.e. for fullscreen mode)
  showPoster: (opts) ->
    return unless @canvas

    @canvas.clear()
    @canvas.container.html('')
    poster = @canvas.layer 'poster'

    if @$.is.string opts
      opts = src: opts

    unless opts.width
      opts.width = @scenario.active?.size?.width

    poster.css width: opts.width if opts.width

    # add the poster close button
    if opts.src
      close = @canvas.dom '<a class="close close-button" href="#" />'
      close.on 'click', =>
        @.cleanup()
        return false
      poster.append close
    # add the poster image
    poster.append @canvas.dom '<img />', src: opts.src, alt: '', class: 'image' if opts.src
    # add the poster message
    unless opts.not_support
      message = '<a class="banner get-flash" href="http://get.adobe.com/ru/flashplayer/" target="_blank" />'
    else
      message = '<span class="banner not-support" />'

    poster.append @canvas.dom message
    @.fitTo poster

    @

  fitTo: (target, fit_all=no, fit_container=yes, fit_target=yes) ->
    return unless target and @canvas # only for jplayer
    setTimeout =>
      if fit_container
        @canvas.container.css width: target.outerWidth(), height: target.outerHeight()

      if fit_target
        (@canvas.dom @canvas.target).css width: target.outerWidth(), height: target.outerHeight()  # fit the main container (if position fixed)

      @canvas.fitTo target if fit_all
    , 30
    @

  setup: () ->
    @canvas.clear()

    @canvas.setup()
    @canvas.container.addClass "-hlab-stage #{@name}"
    @canvas.container.addClass "-brand" if @options.brand

    if @$.platform.mobile_windows # or @$.platform.mobile_opera
      @showPoster src: @options.poster, not_support: yes
      return

    @player.on 'error', =>
      @showPoster @options.poster
      @player.cleanup()
      @scenario.cleanup()

    if @autofit
      @player.on 'meta', =>
        @.fitTo @player.layer

    @scenario.on 'action', (event, action) =>
      action.bind @

    @scenario.play @movies
    @

  cleanup: () ->
    @.emit 'cleanup', @

    @player.cleanup() if @player
    @canvas.cleanup() if @canvas
    @scenario.cleanup() if @scenario

    @movies = null
    @player = null
    @canvas = null
    @scenario = null

    @

  movielist: (movies) ->
    @movies = {}
    for name in movies
      @movies[name] = @settings.movie name
      # ...не забываем проименовать
      @movies[name].name = name
    @

  use: (scenario) ->
    return @ if scenario is @scenario?.name

    delete @scenario?['name']

    @scenario = @settings.scenario scenario
    @scenario.name = scenario

    @scenario.on 'select', (movie, index) =>
      @.setupPlayer movie

    @scenario.on 'cleanup', (movie, index) =>
      movie.reset()

    changeAttribute = (movie, option, value) =>
      movie[option] = value if option of movie

    @scenario.on 'setup.movie', changeAttribute
    @scenario.on 'cleanup.movie', changeAttribute

    hooks = {}
    @scenario.on 'setup.movie.listen', (movie, event, handler) =>
      hooks[event] = [] unless hooks[event]
      hooks[event].push handler
      @player.on event, handler

    @scenario.on 'cleanup.movie.listen', (movie, event) =>
      @player.off event, hook for hook in hooks[event]
      delete hooks[event]
    @

  msg:
    DOWNLOAD_FLASH: 'Для проигрывания этого видео установите Flash-проигрыватель'

hLab.use 'movies', Stage: Stage
