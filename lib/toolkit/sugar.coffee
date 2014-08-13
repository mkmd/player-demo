merge = (object, properties) ->
  for key, val of properties
    if (not hLab.is.array val) and hLab.is.object val
      val = merge {}, val

    object[key] = val
  object

hLab.ex.path =
  abs: (path) ->
    return path if (path.indexOf 'http://') >= 0
    'http://' + (window.location.host + '/' + path).replace '//', '/'

hLab.ex.object =
  merge: (objects...) -> #Object::
    first = objects[0]
    merge first, object for object in objects[1..]
    first

  clone: (object) -> #Object::
    return object if not object? or typeof object isnt 'object'

    if object instanceof Date
      return new Date object.getTime()

    if object instanceof RegExp
      flags = ''
      flags += 'g' if object.global?
      flags += 'i' if object.ignoreCase?
      flags += 'm' if object.multiline?
      flags += 'y' if object.sticky?
      return new RegExp object.source, flags

    newInstance = new object.constructor()
    newInstance[key] = @.clone object[key] for key of object
    newInstance

  keys: (object) ->
    key for key of object


hLab.ex.string =
  guid: (digits=8) ->
    id = ''
    id += Math.random().toString(36).substr(2) while id.length < digits
    id.substr 0, digits

hLab.ex.list =
  unique: (list) ->
    output = {}
    output[list[key]] = list[key] for key in [0...list.length]
    value for key, value of output

  map: () ->


  reduce: () ->


  filter: () ->


  diff: (a1, a2) ->
    a = []
    diff = []

    `for (var i=0;i<a1.length;i++) {
      a[a1[i]] = true;
    }
    for(var i=0;i<a2.length;i++){
      if(a[a2[i]]) delete a[a2[i]];
      else a[a2[i]]=true;
    }
    for(var k in a){
      diff.push(k);
    }`

    diff
