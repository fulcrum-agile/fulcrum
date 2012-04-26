if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.ColumnView = Backbone.View.extend({

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
    if (this.options.sortable) {
      this.setSortable();
    }
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
  },

  // Adds the sortable behaviour to the column.
  setSortable: function() {
    this.storyColumn().sortable({
      handle: '.story-title', opacity: 0.6, items: ".story:not(.accepted)",
      update: function(ev, ui) {
        ui.item.trigger("sortupdate", ev, ui);
      }
    });
  },

  // Returns the current visibility state of the column.
  hidden: function() {
    return this.$el.is(':hidden');
  }
});
