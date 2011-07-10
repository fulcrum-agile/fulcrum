var Project = Backbone.Model.extend({
  name: 'project',

  initialize: function(args) {

    this.maybeUnwrap(args);

    this.bind('change:last_changeset_id', this.updateChangesets);

    this.stories = new StoryCollection;
    this.stories.url = this.url() + '/stories';
    this.stories.project = this;

    this.users = new UserCollection;
    this.users.url = this.url() + '/users';
    this.users.project = this;
  },

  url: function() {
    return '/projects/' + this.id;
  },

  // This method is triggered when the last_changeset_id attribute is changed,
  // which indicates there are changed or new stories on the server which need
  // to be loaded.
  updateChangesets: function() {
    var from = this.previous('last_changeset_id');
    if (from === null) {
      from = 0;
    }
    var to = this.get('last_changeset_id');

    var model = this;
    var options = {
      type: 'GET',
      dataType: 'json',
      success: function(resp, status, xhr) {
        model.handleChangesets(resp);
      },
      data: {from: from, to: to},
      url: this.url() + '/changesets'
    };

    $.ajax(options);
  },

  // (Re)load each of the stories described in the provided changesets.
  handleChangesets: function(changesets) {
    var that = this;

    var story_ids = _.map(changesets, function(changeset) {
      return changeset.changeset.story_id;
    });
    story_ids = _.uniq(story_ids);

    _.each(story_ids, function(story_id) {
      // FIXME - Feature envy on stories collection
      var story = that.stories.get(story_id);
      if (story) {
        // This is an existing story on the collection, just reload it
        story.fetch();
      } else {
        // This is a new story, which is present on the server but we don't
        // have it locally yet.
        that.stories.add({id: story_id});
        story = that.stories.get(story_id);
        story.fetch();
      }
    });
  }
});
