var StoryCollection = Backbone.Collection.extend({
  model: Story,

  comparator: function(story) {
    return story.position();
  },

  next: function(story) {
    return this.at(this.indexOf(story) + 1);
  },

  previous: function(story) {
    return this.at(this.indexOf(story) - 1);
  }
});
