
class LinkButton extends hLab.ui.Widget

  constructor: (options=null) ->
    super()
    @fit = yes
    @[name] = option for name, option of options if options

  setup: () ->
    target = @canvas.container

    return if @container or (target.children "#link-button[#{@id}]").length
    @container = @.dom """<a id="link-button[#{@id}]" class="link-button"></a>"""
    if @url
      @container.attr 'url', @url
      @container.attr 'target': '_blank'

    if @css
      cls = @css.class  # todo: clone
      delete @css['class']
      @container.css @css
      @container.addClass cls if cls

    target.append @container
    @canvas.aslayer @container, 'link-button'

    if @flow
      @container.on 'click', =>
        @context.scenario.select @flow
        return no
    @

  cleanup: () ->
    return unless @container
    @container.remove()
    @container = null
    @

  fitTo: (layer) ->
    return unless @fit
    @canvas.fitTo layer, 'link-button'
    @

  show: () ->
    @container.show() if @container
    @

  hide: () ->
    @container.hide() if @container
    @

hLab.use 'ui', LinkButton: LinkButton