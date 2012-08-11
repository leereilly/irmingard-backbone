'use strict'

class IG.Views.ColumnsCollection extends Backbone.Marionette.CompositeView
  tagName: 'div'
  id: 'columns-container'
  template: 'columns/collection'
  itemView: IG.Views.ColumnsShow
  itemViewContainer: '#columns-wrapper'