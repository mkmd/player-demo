
class Action

  constructor: (options=null) ->
    @id = @$.string.guid 8
    @[name] = option for name, option of options if options

  run: (args=null) ->
    @

  cleanup: (args=null) -> #undo
    @

  bind: (context) ->
    @context = context
    @


hLab.use 'actions', Action: Action