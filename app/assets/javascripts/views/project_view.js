if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.ProjectView = Backbone.View.extend({

  initialize: function() {

    this.columns = {};

    _.bindAll(this, 'addStory', 'addAll', 'render');

    this.model.stories.bind('add', this.addStory);
    this.model.stories.bind('reset', this.addAll);
    this.model.stories.bind('all', this.render);
    this.model.bind('change:userVelocity', this.addAll);

    this.model.stories.fetch();
  },

  // Triggered when the 'Add Story' button is clicked
  newStory: function() {
    this.model.stories.add([{
      events: [], editing: true
    }]);
  },

  addStory: function(story, column) {
    // If column is blank determine it from the story.  When the add event
    // is bound on a collection, the callback sends the collection as the
    // second argument, so also check that column is a string and not an
    // object for those cases.
    if (typeof column === 'undefined' || typeof column !== 'string') {
      column = story.column;
    }
    var view = new Fulcrum.StoryView({model: story}).render();
    this.appendViewToColumn(view, column);
    view.setFocus();
  },

  appendViewToColumn: function(view, columnName) {
    $(columnName).append(view.el);
  },

  addIteration: function(iteration) {
    var that = this;
    var column = iteration.get('column');
    var view = new Fulcrum.IterationView({model: iteration}).render();
    this.appendViewToColumn(view, column);
    _.each(iteration.stories(), function(story) {
      that.addStory(story, column);
    });
  },

  addAll: function() {
    $(".loading_screen").show();
    var that = this;

    $('#done').html("");
    $('#in_progress').html("");
    $('#backlog').html("");
    $('#chilly_bin').html("");

    this.model.rebuildIterations();

    // Render each iteration
    _.each(this.model.iterations, function(iteration) {
      var column = iteration.get('column');
      that.addIteration(iteration);
    });

    // Render the chilly bin.  This needs to be rendered separately because
    // the stories don't belong to an iteration.
    _.each(this.model.stories.column('#chilly_bin'), function(story) {
      that.addStory(story);
    });
    $(".loading_screen").hide();
  },

  scaleToViewport: function() {
    var storyTableTop = $('table.stories tbody').offset().top;
    // Extra for the bottom padding and the
    var extra = 100;
    var height = $(window).height() - (storyTableTop + extra);
    $('.storycolumn').css('height', height + 'px');
  },

  notice: function(message) {
    $.gritter.add(message);
  },

  addColumnView: function(id, view) {
    this.columns[id] = view;
  }
});
