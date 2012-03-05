var NoteView = Backbone.View.extend({
  tagName: 'div',

  className: 'note',

  render: function() {
    $(this.el).html($('#note_tmpl').tmpl({note: this.model}));
    return this;
  }
});
