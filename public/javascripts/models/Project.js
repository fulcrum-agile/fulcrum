var Project = Backbone.Model.extend({
  name: 'project',

  initialize: function() {
    this.stories = new StoryCollection;
    this.stories.url = this.url() + '/stories';
  },

  url: function() {
    return '/projects/' + this.id;
  },
});
