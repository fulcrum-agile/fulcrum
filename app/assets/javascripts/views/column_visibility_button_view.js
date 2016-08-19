module.exports = Backbone.View.extend({

  events: {
    'click': 'toggle'
  },

  tagName: 'a',

  attributes: {
    href: '#'
  },

  initialize: function() {
    _.bindAll(this, 'setClassName');
    this.$el.attr('class','hide_'+this.options.columnView.id );
    this.options.columnView.on('visibilityChanged', this.setClassName);
  },

  render: function() {
    var icon = "";
    switch(this.options.columnView.id) {
    case 'done' :
      icon = '<i class="mi md-18">done</i> ';
      break;
    case 'in_progress' :
      icon = '<i class="mi md-18">inbox</i> ';
      break;
    case 'backlog' :
      icon = '<i class="mi md-18">list</i> ';
      break;
    case 'chilly_bin' :
      icon = '<i class="mi md-18">ac_unit</i> ';
      break;
    case 'search_results' :
      icon = '<i class="mi md-18">search</i> ';
      break;
    }
    this.$el.html(icon + this.options.columnView.name());
    this.setClassName();
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
