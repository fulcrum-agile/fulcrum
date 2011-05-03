var AppView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'addOne', 'addAll', 'render');

    window.Project.stories.bind('add', this.addOne);
    window.Project.stories.bind('refresh', this.addAll);
    window.Project.stories.bind('all', this.render);

    window.Project.stories.fetch();
  },

  addOne: function(story) {
    var view = new StoryView({model: story, id: story.id, className: story.className()});
    $(story.get('column')).append(view.render().el);
  },

  addAll: function() {
    window.Project.stories.each(this.addOne);
  },

  scaleToViewport: function() {
    // TODO Make this a calculated value
    var height = $(window).height() - 250;
    $('.storycolumn').css('height', height + 'px');
  }
});
