var StoryCollection = Backbone.Collection.extend({
  model: Story,

  initialize: function() {
    this.bind('change:position', this.sort);
    this.bind('change:state', this.sort);
    this.bind('change:estimate', this.sort);
  },

  comparator: function(story) {
    return story.position();
  },

  next: function(story) {
    return this.at(this.indexOf(story) + 1);
  },

  previous: function(story) {
    return this.at(this.indexOf(story) - 1);
  },

  // Returns all the stories in the named column, either #done, #in_progress,
  // #backlog or #chilly_bin
  column: function(column) {
    return this.select(function(story) {
      return story.column() == column;
    });
  },

  // Returns an array of the stories in a set of columns.  Pass an array
  // of the column names accepted by column().
  columns: function(columns) {
    var that = this;
    return _.flatten(_.map(columns, function(column) {
      return that.column(column);
    }));
  }
});
