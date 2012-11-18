if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.NoteView = Backbone.View.extend({

  template: JST['templates/note'],

  tagName: 'div',

  className: 'note',

  events: {
    "click a.delete-note": "deleteNote"
  },

  render: function() {
    this.$el.html(this.template({note: this.model}));
    return this;
  },
  
  deleteNote: function() {
  	this.model.destroy();
  	this.$el.remove();
  	return false;
  }
});
