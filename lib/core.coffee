return if hLab?

class window.hLab

  imports = []
  modules = []
  sandbox = null

  parseNamespace = (namespace) ->
    match = namespace.match /(.+)@(.+)?/
    return [@, namespace] if not (match and match.length)
    return if not sandbox? [match[1]]
    [sandbox[match[1]], match[2] || '']

  use: (namespace, members = null) -> #require-define
    [module, namespace] = parseNamespace.call @, namespace

    return unless module

    namespace = namespace.split '.'
    return module unless namespace[0]
    imports.push namespace[0] if namespace[0] not in imports

    for ns in namespace
      module[ns] = {} if not module[ns]
      module = module[ns]

    return module unless members

    for own as, member of members
      if module[as]
        console.warn @.msg.ATTEMPT_TO_OVERRIDE_NAME, "#{namespace}.#{as}"
        continue
      if @.is.callable member #typeof member == 'function'
        member::$ = @
        modules.push member
      module[as] = member

    module

  sandbox: (name) -> #branch
    return if (sandbox ?= {})[name]

    class hLab

    sandbox[name] = hLab
    sandbox[name]:: = @.ex
    sandbox[name] = new hLab

    for nm in imports
      sandbox[name][nm] = @[nm]
      delete @[nm]

    for module in modules
      module::$ = sandbox[name]

    imports = []
    modules = []
    sandbox[name]

  msg:
    ATTEMPT_TO_OVERRIDE_NAME: 'You are trying to override the busy name:'

  ex: @::
  hLab = new @
