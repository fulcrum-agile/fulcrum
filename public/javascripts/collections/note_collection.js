var NoteCollection = Backbone.Collection.extend({
  model: Note,

  url: function() {
    return this.story.url() + '/notes';
  }
});
