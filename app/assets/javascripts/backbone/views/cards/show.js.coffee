'use strict'

class IG.Views.CardsShow extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'm-card'

  initialize: ->
    _.bindAll @, 'render'
    @template = 'cards/show'
    @model.on 'change:open change:draggable', @render
    @model.on 'change:draggable', @setDraggable
    @setDraggable()

  render: ->
    super()

  events:
    # the implicit selector is li.m-card' and afaik there's no way to listen only to events on li.m-card[draggable="true"]
    'dragstart': 'handleDragStart'
    'dragenter': 'handleDragEnter'
    'dragover':  'handleDragOver'
    'dragleave': 'handleDragLeave'
    'dragend':   'handleDragEnd'
    'drop':      'handleDrop'

  setDraggable: =>
    $(@el).attr 'draggable', "#{@model.get 'draggable'}"

  getDragTarget: ($dragEventTarget) ->
    if $dragEventTarget.hasClass('m-card')
      $dragTarget = $dragEventTarget
    else
      $parent = $dragEventTarget.parent('.m-card')
      if $parent.length
        $dragTarget = $parent
    $dragTarget

  handleDragStart: (event) ->
    return false unless @model.get 'draggable'
    IG.currentlyDraggedCard = @model
    $(@el).addClass 'low-opacity'

  handleDragEnter: (event) ->
    return unless @model.isDropTargetFor(IG.currentlyDraggedCard)
    @getDragTarget($ event.target).addClass 'drop-hovered'

  handleDragOver: (event) ->
    # the following two lines are mandatory for the 'drop' event to fire
    event.preventDefault()
    return false

  handleDragLeave: (event) ->
    @getDragTarget($ event.target).removeClass 'drop-hovered'

  handleDragEnd: (event) ->
    $(@el).removeClass 'low-opacity'
    IG.currentlyDraggedCard = undefined

  handleDrop: (event) ->
    event.stopPropagation()
    event.preventDefault()
    return unless @model.isDropTargetFor(IG.currentlyDraggedCard)

    if IG.currentlyDraggedCard.isLastCardInColumn(IG.currentlyDraggedCard.get('column'))
      IG.currentlyDraggedCard.moveTo @model.get('column')
    else
      cardsToMove = IG.currentlyDraggedCard.get('column').cardsBelow(IG.currentlyDraggedCard)
      cardsToMove.unshift IG.currentlyDraggedCard
      _.each cardsToMove, (card) =>
        card.moveTo @model.get('column')

    @getDragTarget($ event.target).removeClass 'drop-hovered'
    IG.currentlyDraggedCard = undefined

  # custom function to put some additional meat on 'this' used in the CardsShow template
  # manually adding the output of certain functions that would otherwise
  # not be accessible from the template
  # cf.: http://stackoverflow.com/a/10779124 and
  # http://derickbailey.github.com/backbone.marionette/docs/backbone.marionette.html
  serializeData: ->
    jsonData = @model.toJSON()
    jsonData.humanReadableShort = @model.humanReadableShort()
    jsonData.imagePath = @model.imagePath()
    jsonData
