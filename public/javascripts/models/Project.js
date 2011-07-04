var Project = Backbone.Model.extend({
  name: 'project',

  initialize: function() {
    this.stories = new StoryCollection;
    this.stories.url = this.url() + '/stories';
    this.stories.project = this;

    this.users = new UserCollection;
    this.users.url = this.url() + '/users';
    this.users.project = this;
  },

  url: function() {
    return '/projects/' + this.id;
  }
});
