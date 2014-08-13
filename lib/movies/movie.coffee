class Movie extends hLab.lib.Emitter

  constructor: (options=null) ->
    super()
    return unless options

    for attr, value of options
      switch attr
        when 'src'
          @use value
        else
          @[attr] = value

    @.is =
      loading: false
      loaded: false
      played: false
      playing: false
      paused: false
      seeking: false
      muted: false
      fullscreen: false
      ready: false

    defaults.call @

  use: (src, abs=yes) ->
    return unless src

    @sources = []
    src = [src] if not @$.is.array src
    for source in src
      if @$.is.string source
        src = {}
        src[source[((source.lastIndexOf '.')+1)..]] = source
        source = src

      continue unless @$.is.object source

      for type, path of source
        if @$.is.string path
          source[type] = {}
          source[type][if type is 'flv' then 'flash' else 'html'] = path

        unless @$.is.object source[type]
          delete source[type]

        source[type][platform] = @$.path.abs path for platform, path of source[type] if abs

      @sources.push source
    @

  paths: () ->
    paths = []

    for source in @sources
      break for type, src of source
      paths.push path for platform, path of src

    @$.list.unique paths

  types: () ->
    types = []

    for source in @sources
      for type, sources of source
        types.push type
        for platform, src of sources
          if platform is 'flash'
            types.push 'flv'
            break

    types

  reset: () ->
    return if @persist

    @buffered = 0
    @source = ''
    @type = ''
#    @speed = 0  # 1
#    @volume = 0  # 50
    @time = 0
    @progress = 0
    @is[attr] = no for attr of @is

    defaults.call @

  # deprecated
  cuepoint: (name, time) ->
    @

  subtitle: (name, content) ->
    @

  dumps: () ->
    cuepoints: @cuepoints
    duration: @duration
    width: @width
    height: @height
    size: @size
    type: @type
    speed: @speed
    volume: @volume
    source: @source
    sources: @sources
    group: @group

  defaults = () ->
    tech = @$.movies?.tech?.options?.defaults
    return unless tech

    @volume = parseInt tech.volume unless @volume
    @speed = parseInt tech.speed unless @speed
    @persist = no

#  autoplay: false
#  loop: false
  subtitles: null
  cuepoints: null
  duration: 0
  width: 0
  height: 0
#  seekable: false # use .supports to detect (in html5 mode)
  source: ''
  type: ''
  speed: 0  # 1
  volume: 0  # 50
  time: 0
  buffered: 0  # as many loaded in Kb (only in streaming mode)
  progress: 0

  ex: @::

hLab.use 'movies', Movie: Movie
