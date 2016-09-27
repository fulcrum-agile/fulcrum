var Note = require('models/note');

module.exports = Backbone.Collection.extend({
  model: Note,

  url: function() {
    return this.story.url() + '/notes';
  },

  saved: function() {
    return this.reject(function(note) {
      return note.isNew();
    });
  }
});
