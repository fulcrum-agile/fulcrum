var ProjectView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'addStory', 'addAll', 'render');

    this.model.stories.bind('add', this.addStory);
    this.model.stories.bind('reset', this.addAll);
    this.model.stories.bind('all', this.render);

    this.model.stories.fetch();
  },

  addStory: function(story, column) {
    // If column is blank determine it from the story.  When the add event
    // is bound on a collection, the callback sends the collection as the
    // second argument, so also check that column is a string and not an
    // object for those cases.
    if (typeof column === 'undefined' || typeof column !== 'string') {
      column = story.column();
    }
    var view = new StoryView({model: story});
    $(column).append(view.render().el);
  },

  addIteration: function(iteration) {
    var that = this;
    var column = iteration.get('column');
    var view = new IterationView({model: iteration});
    $(column).append(view.render().el);
    _.each(iteration.get('stories'), function(story) {
      that.addStory(story, column);
    });
  },

  addAll: function() {

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
    this.loadTags();
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

  loadTags: function(){
    this.availableTags = _.compact(
      _.uniq(
        _.flatten(
          _.map( this.model.stories.models, function(story){
            if(story.get('labels')){
              return _.map( story.get('labels').split(','), function(label){
                return $.trim(label);
              });
            }
          })
        )
      )
    );
  }
});
