if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.StoryCollection = Backbone.Collection.extend({
  model: Fulcrum.Story,

  initialize: function() {
    this.bind('change:position', this.sort);
    this.bind('change:state', this.sort);
    this.bind('change:estimate', this.sort);
    this.bind('change:labels', this.addLabelsFromStory);
    this.bind('add', this.addLabelsFromStory);
    this.bind('reset', this.resetLabels);

    this.labels = [];
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
      return story.column == column;
    });
  },

  // Returns an array of the stories in a set of columns.  Pass an array
  // of the column names accepted by column().
  columns: function(columns) {
    var that = this;
    return _.flatten(_.map(columns, function(column) {
      return that.column(column);
    }));
  },

  // Takes comma separated string of labels and adds them to the list of
  // availableLabels.  Any that are already present are ignored.
  addLabels: function(labels) {
    return (this.labels = _.union(this.labels,labels));
  },

  addLabelsFromStory: function(story) {
    return this.addLabels(story.labels());
  },

  resetLabels: function() {
    var collection = this;
    collection.each(function(story) {
      collection.addLabelsFromStory(story);
    });
  }
});
