var Task = require('models/task');

module.exports = Backbone.Collection.extend({
  model: Task,

  url: function() {
    return this.story.url() + '/tasks';
  },

  saved: function() {
    return this.reject(function(task) {
      return task.isNew();
    });
  }
});
