if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.ColumnVisibiltyButtonView = Backbone.View.extend({

  events: {
    'click': 'toggle'
  },

  tagName: 'a',

  attributes: {
    'href':  '#',
    'class': 'btn'
  },

  initialize: function() {
    _.bindAll(this, 'setClassName');
    this.options.columnView.bind('visibilityChanged', this.setClassName);
  },

  render: function() {
    this.$el.html(this.options.columnView.name());
    return this;
  },

  // Delegates to toggle() on the associated ColumnView
  toggle: function() {
    this.options.columnView.toggle();
  },

  setClassName: function() {
    if (this.options.columnView.hidden()) {
      this.$el.addClass('pressed');
    } else {
      this.$el.removeClass('pressed');
    }
  }
});
