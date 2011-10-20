var NoteView = Backbone.View.extend({
  tagName: 'div',

  className: 'note',

  render: function() {
    $(this.el).html($('#note_tmpl').tmpl(this.model.toJSON()));
    return this;
  }
});
