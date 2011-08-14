var NoteCollection = Backbone.Collection.extend({
  model: Note,
  url: function() {
    return	this.collection.story.url() + '/notes'
  }
});