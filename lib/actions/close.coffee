
class Close extends hLab.actions.Action

  run: (args) ->
    print.log '...closing stage'

    setTimeout =>
      if @poster
        @context.canvas.container.parent().append @context.canvas.dom '<img />', src: @poster

      @context.cleanup()
    , 100 # all event "end"-hook must be done before
    @

hLab.use 'actions', Close: Close