
class Scenario extends hLab.lib.Emitter

  setup = (movie, index) ->
    @.emit 'setup', movie, index

    handleEvent = (args...) ->
      [event, listener, args] = args

      action = @settings.action listener,
                                nocache: no,
                                etag: (ns) -> JSON.stringify listener
      action.bind @
      @.once 'cleanup', -> action.cleanup()
      @.emit 'action', event, action

      action.run args

    for name, opt of @flow[index]
      if name is 'on'
        for event, eventOpt of opt
          listeners = []
          if @$.is.array eventOpt
            Array::push.apply listeners, eventOpt
          else
            listeners.push eventOpt

          @emit 'setup.movie.listen', movie, event, handleEvent.bind @, event, listener for listener in listeners
      else
        @emit 'setup.movie', movie, name, opt
    @

  cleanup = (movie, index) ->
    @.emit 'cleanup', movie, index
    for name, opt of @flow[index]
      if name is 'on'
        @emit 'cleanup.movie.listen', movie, event for event, eventOpt of opt
      else
        @emit 'cleanup.movie', movie, name, undefined

  constructor: (options) ->
    super()

    handle = (args...) ->
      [event, listener, args] = args
      action = @settings.action listener
      action.bind @
      @.emit 'action', event, action
      action.run args

    @settings = options.settings
    for name, option of options
      switch name
        when 'flow' then @.use options.flow
        when 'on'
          for event, eopt of option
            listeners = []
            if @$.is.array eopt
              Array::push.apply listeners, eopt
            else
              listeners.push eopt
            @.on event, handle.bind @, event, listener for listener in listeners
        else @[name] = option

    @index = null
    @active = null
    @movies = []

  cleanup: () ->
    @.off()

    @active = null
    @movies = null
    @flow = null
    @

  use: (src) ->
    @flow = src or []
    @length = @flow.length
    @

  select: (index, force=no) ->
    return if index is @index and not force

    # get the movie index if Movie-object is passed
    if @$.is.object index
      for movie, index_ in @movies
        if movie.id is index.id
          index = index_
          break

    return if 0 > index >= @length
    return unless @flow[index] and @movies[index]

    @.is.first = !index
    @.is.last = index is @length-1

    if @active
      cleanup.call @, @active, @index

    @index = @$.as.number index
    @active = @movies[index]

    setup.call @, @active, @index

    @emit 'select', @active, @index
    @

  next: () ->
    @.select @index+1 #if @index < flow.length

  prev: () ->
    @.select @index-1

  play: (movies=null) ->
    @movies = (movie for name, movie of movies) if movies
    return if @movies.length isnt @flow.length
    @.emit "play"
    @

  # deprecated
  is:
    first: false
    last: false

hLab.use 'movies.scenarios', Scenario: Scenario