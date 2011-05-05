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
    $(story.column()).append(view.render().el);
  },

  addAll: function() {
    $('#done').html("");
    $('#in_progress').html("");
    $('#backlog').html("");
    $('#chilly_bin').html("");
    window.Project.stories.each(this.addOne);
  },

  scaleToViewport: function() {
    var storyTableTop = $('table.stories tbody').offset().top;
    // Extra for the bottom padding and the 
    var extra = 100;
    var height = $(window).height() - (storyTableTop + extra);
    $('.storycolumn').css('height', height + 'px');
  }
});
