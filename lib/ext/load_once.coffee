
class LoadOnce extends hLab.actions.Action

  run: (args) ->
    print.log '...check loading restricts'
    return unless @context.stages

    @key = @key or 'speaker'
    @days ?= null

    storage = monster.get @key
    storage ?= {}

    if @times
      @.invalidateTimes storage
    else
      @.invaidateDefault storage

    @

  invalidateTimes: (storage) ->
    storage.visits = (parseInt storage.visits) or 0

    if storage.visits > @times  # times
      return @.terminate()

    storage.visits++
    monster.set @key, storage, @days

  invalidateDefault: (storage) ->
    if storage.stage
      return @.terminate()

    for name, stage of @context.stages
      do (name, stage) =>
        stage.player.on 'play', =>
          return unless stage.player.movie.group is @group
          monster.set @key, stage: name, @days

  terminate: () ->
    @context.cleanup()
    return


hLab.use 'ext', LoadOnce: LoadOnce