queue = null

hLab.ex.fn =
  defer: (fn) ->
    (queue ?= []).push fn

  curry: (fn, args...) ->
    () ->
      fn args...

  partial: (fn, args...) ->
    (nested...) ->
      args = Array::push.apply args, nested
      fn args...

hLab.ex.fn.defer.now = (args...) -> #go
  fn args... for fn in queue if queue
  queue = null
#    delete @['queue']
