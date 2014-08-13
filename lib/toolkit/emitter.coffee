
class Emitter

  supress = null

  constructor: ->
    @evnts = {}

  on: (event, listener) ->
    for event in event.split ' '
      [group, event] = event.split ':'
      unless event
        event = group
        group = 'default'

      @emit 'on', event, listener

      @evnts[group] ?= {}
      @evnts[group][event] ?= []
      @evnts[group][event].push listener

  off: (event, listener=null) ->
    unless event # clear all
      @evnts = {}
      return @
    for event in event.split ' '
      [group, event] = event.split ':'
      unless event
        event = group
        group = 'default'

      return delete @evnts[group] if event is '*' and @evnts[group]?

      return @ unless @evnts[group]?[event]?
      unless listener
        delete @evnts[group][event]
        return @

      @evnts[group][event] = (fn for fn in @evnts[group][event] when fn isnt listener)
    @

  once: (event, listener) ->
    fn = =>
      @off event, fn
      listener arguments...

    @on event, fn
    fn

  emit: (event, args...) ->
    for event in event.split ' '
      listener args... for listener in listeners\
        for ev, listeners of events when ev is event\
          for group, events of @evnts
    @

  events: ->
    group = 'default'
    event for event of @evnts[group] if @evnts? and @evnts[group]?

  listeners: (event) ->
    [group, event] = event.split ':'
    unless event
      event = group
      group = 'default'

    listener for listener in @evnts[group][event] if @evnts[group]?[event]?

  silent: (events=null) ->
    return supress = null if not events
    supress = events
    @

hLab.use 'lib', Emitter: Emitter


