var ColumnView = Backbone.View.extend({

  template: JST['templates/column'],

  tagName: 'td',

  events: {
    'click a.toggle-column': 'toggle'
  },

  name: function() {
    return this.options.name;
  },

  render: function() {
    this.$el.html(this.template({id: this.id, name: this.name()}));
    return this;
  },

  toggle: function() {
    this.$el.toggle();
    this.trigger('visibilityChanged');
  },

  // Returns the child div containing the story and iteration elements.
  storyColumn: function() {
    return this.$('.storycolumn');
  },

  // Append a Backbone.View to this column
  appendView: function(view) {
    this.storyColumn().append(view.el);
  }
});
