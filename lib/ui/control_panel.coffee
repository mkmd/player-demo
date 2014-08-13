
class ControlPanel extends hLab.ui.Widget

  VOLUMEBAR_TOP_PAD = 8 # top padding to volume line
  VOLUMEBAR_BOTTOM_PAD = 6

  trackTrackGrip = trackMouseUp = trackVolumeGrip = null

  fit = (element, to) ->
    return unless to

    [v, h] = to.position.split ' '
    [v, h] = [h, v] if v in ['center', 'left', 'right']

    element.css
      margin: "#{to.top}px 0px 0px #{to.left}px"
      width: to.width
      height: to.height

    box = element.children '.control-panel-box'
    offsetTop = Math.round(box.height() / 2)
    offsetLeft = Math.round(box.width() / 2)

    css = {}
    if v is 'top' then css.top = 0
    else if v is 'bottom' then css.bottom = 0
    else
      css.top = '50%'
      css.marginTop = "-#{offsetTop}px"

    if h is 'left' then css.left = 0
    else if h is 'right' then css.right = 0
    else
      css.left = '50%'
      css.marginLeft = "-#{offsetLeft}px"

    box.css css
    @

  render = (controls) ->
    return unless controls
    len = controls.length
    return (control.call @, index, len for control, index in controls).join ''

  cell = (html, index, total) ->
    unless index
      # <a[^>]*>[^<]*<\/a>
      return if /href="[^"]+"/i.test html then """<span class="cell first">#{html}</span>""" else """<a href="#" class="cell first">#{html}</a>"""
    return """<a href="#" class="cell last">#{html}</a>""" if index is total - 1
    """<a href="#" class="cell">#{html}</a>"""

  view = (name) ->
    controls = null
    switch name
      when 'A'
        controls = [(playpause.bind @), (trackbar.bind @), (volumebar.bind @), (split.bind @), (close.bind @)]
      when 'B'
        controls = [(playpause.bind @), (split.bind @), (volumebar.bind @), (split.bind @), (close.bind @)]
      when 'C'
        controls = [(playpause.bind @), (split.bind @), (close.bind @)]
      when 'D'
        controls = [(playpause.bind @), (split.bind @), (volumebar.bind @)]

    controls.unshift (logotype.bind @) if @logotype and controls
    return render.call @, controls if controls

  split = () -> #delimiter
    return '<span class="split"></span>'

  logotype = (index, total) ->
    return cell.call @, '<a href="#" target="_blank" class="logotype"></a>', index, total

  playpause = (index, total) ->
    html = '<span class="play-pause"></span>'
    cell.call @, html, index, total

  trackbar = () ->
    html = '<span class="trackbar"><span class="line"></span><span class="grip"></span></span>'

    trackbar.set = (percents) ->
      $trackBar = (@container.find '.trackbar')
      $grip = $trackBar.find '.grip'

      width = $trackBar.width() - $grip.width()
      $grip.css left: width * (percents / 100) + 'px'

    trackbar.get = () ->
      Math.ceil @container.attr 'data-seek'

    html

  volumebar = (index, total) ->
    html = '<span class="mute-unmute"><span class="volumebar"><span class="line"></span><span class="grip"></span></span></span>'

    volumebar.set = (percents) ->
      $volumeBar = (@container.find '.volumebar')
      $grip = $volumeBar.find '.grip'

      height = $volumeBar.height() - VOLUMEBAR_TOP_PAD - VOLUMEBAR_BOTTOM_PAD - $grip.height()
      $grip.css top: VOLUMEBAR_TOP_PAD + height * ((100 - percents) / 100) + 'px'

    volumebar.get = () ->
      Math.ceil @container.attr 'data-volume'

    cell.call @, html, index, total

  close = (index, total) ->
    html = '<span class="close"></span>'

    cell.call @, html, index, total

  constructor: (options = null) ->
    super()
    @[name] = option for name, option of options if options

  setup: (to = null) ->
    print.log '...showing control panel', @id

    # target is owner of control-panel container element
    # find owner element
    if to  # to custom element
      @target = @dom to
    else if @$.is.string @layer  # to custom layer
      @target = @canvas.layer @layer

    @target ?= @canvas.container  # by default, to canvas

    # return if element already exists
    return if @container or (@target.children "#control-panel[#{@id}]").length

    content = view.call @, @view
    return unless content

    # create base DOM-structure
    @container = @.dom """<div id="control-panel[#{@id}]" class="control-panel control-panel-rectangle control-panel-#{@view}">
                       <div class="control-panel-box">#{content}</div></div>"""

    # box is a rectangle, which positioning/bounds the main control elements
    box = @container.find '.control-panel-box'
    # custom css setted
    box.css @css if @css
    # setup (append to DOM) the control
    @target.append @container
    # emulating layer behavior for box (layer z-index is setted in outer scope)
    @canvas.aslayer box, 'control-panel'

    # ie-hack, bl
    if @$.platform.ie and @$.platform.ieVersion < 8
      @container.css 'z-index': box.css 'z-index'
    # pulling grip-control
    (@container.find '.grip').css 'z-index': box.css 'z-index'

    # hiding/showing to prevent blinking on resize
    fit.call @, @container, @rectangle

    # prevent unused "a"-element behavior
    (@container.find 'a.cell').on 'click', (event) ->
      event.stopPropagation()
      event.preventDefault()
      return false

    # do events
    $document = (@dom document)
    $volumeBar = @container.find '.volumebar'
    $volumeLine = $volumeBar.find '.line'
    $volumeGrip = $volumeBar.find '.grip'
    $trackBar = @container.find '.trackbar'
    $trackLine = $trackBar.find '.line'
    $trackGrip = $trackBar.find '.grip'

    # ie fix
    (@dom 'img', @container).on 'dragstart', (event) ->
      event.preventDefault()
      no

    # handle play/pause
    (@container.find '.play-pause').on 'click', (e) =>
      playing = @container.hasClass '-is-playing'
      @.playing not playing
      @.emit if playing then 'pause' else 'play'

    # handle mute/unmute
    (@container.find '.mute-unmute').on 'click', (e) =>
      return if e.target isnt e.currentTarget
      muted = @container.hasClass '-is-muted'
      @.mute not muted
      volumebar.set?.call @, if muted then volumebar.get?.call @ else 0
      @.emit if muted then 'unmute' else 'mute'

    # handle volume-bar
    trackVolumeGrip = (e) =>
      # e.pageY, e.clientY
      offset = $volumeBar.offset()
      # get the height of volume line (grip "rails")
      height = $volumeBar.height() - VOLUMEBAR_TOP_PAD - VOLUMEBAR_BOTTOM_PAD - $volumeGrip.height()

      # calculate and check bounds for grip
      MINY = offset.top + VOLUMEBAR_TOP_PAD
      MAXY = offset.top + VOLUMEBAR_TOP_PAD + height

      if e.clientY < MINY
        @.volume 100
        @.emit 'volume', 100
      if e.clientY > MAXY
        @.volume 0
        @.emit 'volume', 0

      return unless MINY < e.clientY < MAXY

      # calculate offset top for grip
      top = e.clientY - offset.top - VOLUMEBAR_TOP_PAD
      percents = 100 - ((top * 100) / height)

      @.volume percents
      @.emit 'volume', percents

    trackVolume = =>
      $volumeBar.addClass '-visible'
      $document.on 'mousemove', trackVolumeGrip
      no

    $volumeGrip.on 'mousedown', trackVolume
    $volumeLine.on 'mousedown', trackVolume
    $volumeLine.on 'click', trackVolumeGrip

    # handle track-bar
    trackTrackGrip = (e) =>
      # e.pageY, e.clientY
      offset = $trackBar.offset()
      # get the height of volume line (grip "rails")
      width = $trackBar.width() - $trackGrip.width()

      # calculate and check bounds for grip
      MINX = offset.left
      MAXX = offset.left + width

      if e.clientX < MINX
        @.seek 0
        @.emit 'seek', 0
      if e.clientX > MAXX
        @.seek 100
        @.emit 'seek', 100

      return unless MINX < e.clientX < MAXX

      # calculate offset top for grip
      left = e.clientX - offset.left
      percents = (left * 100) / width

      @.seek percents
      @.emit 'seek', percents

    trackSeeking = =>
      @.seeking yes

      trackTrackGrip.apply @, arguments
      $document.on 'mousemove', trackTrackGrip
      no

    $trackGrip.on 'mousedown', trackSeeking
    $trackLine.on 'mousedown', trackSeeking

    # shared event-handling
    trackMouseUp = =>
      $volumeBar.removeClass '-visible'
      $document.off 'mousemove'

      if @.state().seeking
        @.seeking no
        @.emit 'seek.done', trackbar.get?.call @

    $document.on 'mouseup', trackMouseUp

    (@container.find '.close').on 'click', (event) =>
      @.emit 'close'
    @

  cleanup: () ->
    $document = (@dom document)
    $document.off 'mousemove', trackVolumeGrip
    $document.off 'mousemove', trackTrackGrip
    $document.off 'mouseup', trackMouseUp

    @.off()
    return @ unless @container
    @container.off()
    $ = @dom
    (@container.find '*').each -> ($ @).off()
    @container.remove()
    @container = null
    @

  playing: (enable) ->
    return @ unless @container
    unless enable
      @container.removeClass '-is-playing'
      return @
    @container.addClass '-is-playing' unless @container.hasClass '-is-playing'
    @

  seeking: (enable) ->
    return @ unless @container
    unless enable
      @container.removeClass '-is-seeking'
      return @
    @container.addClass '-is-seeking' unless @container.hasClass '-is-seeking'
    @

  mute: (enable) ->
    return @ unless @container
    unless enable
      @container.removeClass '-is-muted'
      return @
    @container.addClass '-is-muted' unless @container.hasClass '-is-muted'
    @

  volume: (percents) ->
    percents = Math.ceil percents  # @$.as.number

    return @ unless @container
    return @ if (volumebar.get?.call @) is percents # return if equal

    @.mute percents is 0
    volumebar.set?.call @, percents
    @container.attr 'data-volume', percents
    @

  seek: (percents) ->
    percents = Math.ceil percents

    return @ unless @container
    return @ if (trackbar.get?.call @) is percents # return if equal
    trackbar.set?.call @, percents
    @container.attr 'data-seek', percents
    @

  safeSeek: (percents) ->
    return @ if @.state().seeking
    @.seek percents

  state: () ->
    playing: @container.hasClass '-is-playing'
    seeking: @container.hasClass '-is-seeking'
    mute: @container.hasClass '-is-muted'
    volume: volumebar.get?.call @
    seek: trackbar.get?.call @

  resize: (rectangle) ->
    return @ unless @container
    @rectangle = rectangle
    fit.call @, @container, rectangle
    @

  show: () ->
    return @ unless @container
    @container.show()
    @

  hide: () ->
    return @ unless @container
    @container.hide()
    @

hLab.use 'ui', ControlPanel: ControlPanel