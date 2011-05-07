var Project = Backbone.Model.extend({
  name: 'project',

  initialize: function() {
    this.stories = new StoryCollection;
    this.stories.url = this.url() + '/stories';
    this.stories.project = this;
  },

  url: function() {
    return '/projects/' + this.id;
  }
});
