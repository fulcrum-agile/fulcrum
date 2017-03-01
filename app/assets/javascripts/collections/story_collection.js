var Story = require('models/story');

module.exports = Backbone.Collection.extend({
  model: Story,

  initialize: function() {
    _.bindAll(this, 'sort', 'addLabelsFromStory', 'resetLabels');
    var triggerReset = _.bind(this.trigger, this, 'reset');

    this.on('change:position', this.sort);
    this.on('change:state', this.sort);
    this.on('change:estimate', this.sort);
    this.on('change:labels', this.addLabelsFromStory);
    this.on('add', this.addLabelsFromStory);
    this.on('reset', this.resetLabels);
    this.on('sort', triggerReset);

    this.labels = [];
  },

  comparator: function(story) {
    return story.position();
  },

  next: function(story) {
    var index = this.indexOf(story) + 1;
    if(index >= this.length) {
      return undefined;
    }

    return this.at(index);
  },

  previous: function(story) {
    var index = this.indexOf(story) - 1;
    if(index < 0) {
      return undefined;
    }

    return this.at(index);
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
