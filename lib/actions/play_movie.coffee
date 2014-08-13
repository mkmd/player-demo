
class PlayMovie extends hLab.actions.Action

  constructor: (options=null) ->
    super options

  run: (args) ->
    print.log '...playing movie', @context.player.id, @context.player.movie.id, @context.player.movie.is.loaded

    return if @context.player.movie.is.playing

    @context.player.play()
    @

hLab.use 'actions', PlayMovie: PlayMovie