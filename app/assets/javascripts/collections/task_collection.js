if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.TaskCollection = Backbone.Collection.extend({
  model: Fulcrum.Task,

  url: function() {
    return this.story.url() + '/tasks';
  },

  saved: function() {
    return this.reject(function(task) {
      return task.isNew();
    });
  }
});

