class Platform

  constructor: () ->
#    msie: /msie [0-6]/
#    ipad: /ipad.*?os [0-4]/
#    iphone: /iphone/
#    ipod: /ipod/
#    android_pad: /android [0-3](?!.*?mobile)/
#    android_phone: /android.*?mobile/
#    blackberry: /blackberry/
#    windows_ce: /windows ce/
#    webos: /webos/

    uagent = navigator.userAgent.toLowerCase()

    detected =
      android: /Android/i.test uagent
      blackberry: /BlackBerry/i.test uagent
      ios: /iPhone|iPad|iPod/i.test uagent
      mobile_opera: /(Opera Mini)|(Opera Tablet)/i.test uagent
      mobile_windows: /IEMobile/i.test uagent
      ie: /msie/i.test uagent
#      ie9: (navigator.appVersion.indexOf 'MSIE 9') >= 0
      chrome: /chrome/i.test uagent
      firefox: /firefox/i.test uagent
      opera: /Opera/i.test uagent
      supports: transparentCanvas: yes

    detected.safari = not detected.chrome and /Safari/i.test uagent
    detected.mobile = detected.android or detected.blackberry or detected.ios or
      detected.mobile_opera or detected.mobile_windows # or yes
    detected.desktop = not detected.mobile

    detected.ieVersion = (/MSIE (\d+)/i.exec navigator.appVersion)?.pop()
    detected.chromeVersion = (/Chrome\/(\d+)/i.exec navigator.appVersion)?.pop()

    detected.supports.canvas = ( ->
      elem = document.createElement 'canvas'
      not not (elem.getContext and elem.getContext '2d')
    )()

    detected.select = (obj) ->
      for key, value of obj
        return value if key in detected and detected[key]
      no

    return detected

hLab.ex.platform = Platform()