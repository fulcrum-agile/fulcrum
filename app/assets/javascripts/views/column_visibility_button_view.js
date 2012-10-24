if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.ColumnVisibilityButtonView = Backbone.View.extend({

  events: {
    'click': 'toggle'
  },

  tagName: 'a',

  attributes: {
    href: '#'
  },

  initialize: function() {
    _.bindAll(this, 'setClassName');
    this.$el.attr('class','hide_'+this.options.columnView.id);
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
