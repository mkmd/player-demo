hLab.ex.type = (value) ->
  return String value unless value?

  fn = arguments.constructor
  unless fn.map #class to type
    fn.map = {}
    fn.map["[object #{name}]"] = name.toLowerCase() for name in 'Boolean Number String Function Array Date RegExp'.split ' ' #Object

  cls = Object::toString.call value
  return fn.map[cls] if cls of fn.map
  'object'

hLab.ex.is =
  empty: (value) ->
    return false if not value
    return value.length is 0 if value.length # obj.length > 0 -> false
    for attr of value
      return false if hasOwnProperty.call value, attr
    return true

  callable: (value) ->
    (hLab.type value) is 'function' and value.call

  array: (value) ->
    (hLab.type value) is 'array' #Array.isArray

  object: (value) ->
    (hLab.type value) is 'object'

  string: (value) ->
    (hLab.type value) is 'string'

  number: (value) ->
    (hLab.type value) is 'number'

  int_: (value) ->


  float_: (value) ->


  bool: (value) ->


hLab.ex.as =
  number: (value, cast=parseFloat) -> #numeric
    (cast value) or 0

  int_: (value) ->
    @number value, parseInt

  float_: () ->
    # toFixed

  string: (value) ->
    value.toString()

  bool: (value) ->
    not not value
