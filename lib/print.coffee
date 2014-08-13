
implement_print = ->
  accept_fn = (name, fn) ->
    # ie-bug: type of console.log isnt Function type: in others browsers weed not function attributes is needed
    return name not in ['memory', 'profiles']

  print = enable: yes
  copy_fn = (fn) ->
    (args...) ->
      return unless @enable
      if fn.call? then fn.call window.console, args... else fn args # ie doesn't support call/apply for console.<method>

  for name, fn of window.console
    fn = copy_fn fn if accept_fn name, fn
    print[name] = fn

  return print

window.print = print = implement_print()
