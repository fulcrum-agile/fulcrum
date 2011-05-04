var StoryCollection = Backbone.Collection.extend({
  model: Story,

  initialize: function() {
    this.bind('change:position', this.sort);
    this.bind('change:state', this.sort);
  },

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
