
class LoopMovie extends hLab.actions.Action

  constructor: (options=null) ->
    super()

  run: (args) ->
    @context.player.play()
    @

hLab.use 'actions', LoopMovie: LoopMovie