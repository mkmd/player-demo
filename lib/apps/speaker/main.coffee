print.enable = no

hLab.apps.Speaker.dom window.jQuery

try
  settings = new hLab.settings.Speaker settings or hLab.settings?.speaker

  hLab.speaker = settings.speaker()

  (window.jQuery window).unload ->
    hLab.speaker.cleanup() if hLab?.speaker

  hLab.speaker.once 'cleanup.done', ->
    ie = hLab.speaker.$.platform.ie and hLab.speaker.$.platform.ieVersion < 9
    window.hLab = null
    delete window["hLab"] unless ie

  hLab.speaker.setup()

  hLab.sandbox settings.sandbox
catch err
  print.log '...error during speaker initializing', err