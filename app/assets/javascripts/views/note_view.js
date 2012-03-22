var NoteView = Backbone.View.extend({

  template: JST['templates/note'],

  tagName: 'div',

  className: 'note',

  render: function() {
    $(this.el).html(this.template({note: this.model}));
    return this;
  }
});
