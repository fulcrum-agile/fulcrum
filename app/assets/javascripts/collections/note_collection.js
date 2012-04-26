if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.NoteCollection = Backbone.Collection.extend({
  model: Fulcrum.Note,

  url: function() {
    return this.story.url() + '/notes';
  },

  saved: function() {
    return this.reject(function(note) {
      return note.isNew();
    });
  }
});
