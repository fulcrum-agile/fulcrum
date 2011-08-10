var AppView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'addOne', 'addAll', 'render');

    window.Project.stories.bind('add', this.addOne);
    window.Project.stories.bind('refresh', this.addAll);
    window.Project.stories.bind('all', this.render);

    window.Project.stories.fetch();
  },

  addOne: function(story) {
    var view = new StoryView({model: story});
    $(story.column()).append(view.render().el);
  },

  addAll: function() {
    $('#done').html("");
    $('#in_progress').html("");
    $('#backlog').html("");
    $('#chilly_bin').html("");

    // FIXME - Refactor
    var that = this;
    var done_iterations = _.groupBy(window.Project.stories.column('#done'),
                                    function(story) {
                                      return story.iterationNumber();
                                    });

    // There will sometimes be gaps in the done iterations, i.e. no work
    // may have been accepted in a given iteration, and it will therefore
    // not appear in the set.  Store this to iterate over those gaps and
    // insert empty iterations.
    var last_iteration = 0;

    _.each(done_iterations, function(stories, iteration) {

      that.fillInEmptyIterations($('#done'), last_iteration, iteration);
      last_iteration = iteration;

      var points = _.reduce(stories, function(memo, story) {
        var estimate = 0;
        if (story.get('story_type') === 'feature') {
          estimate = story.get('estimate') || 0;
        } 
        return memo + estimate;
      }, 0);
      // FIXME - Make a view
      $('#done').append('<div class="iteration">' + iteration + '<span class="points">' + points + ' points</span></div>');
      _.each(stories, function(story) {that.addOne(story)});
    });

    this.fillInEmptyIterations($('#done'), last_iteration, window.Project.currentIterationNumber());

    var points = _.reduce(window.Project.stories.column('#in_progress'), function(memo, story) {
      var estimate = 0;
      if (story.get('story_type') === 'feature' && story.get('state') === 'accepted') {
        estimate = story.get('estimate') || 0;
      } 
      return memo + estimate;
    }, 0);
    $('#in_progress').append('<div class="iteration">' + window.Project.getIterationNumberForDate(new Date()) + '<span class="points">' + 0 + ' points</span></div>');
    _.each(window.Project.stories.column('#in_progress'), this.addOne);
    _.each(window.Project.stories.column('#backlog'), this.addOne);
    _.each(window.Project.stories.column('#chilly_bin'), this.addOne);
  },

  // Creates a set of empty iterations in column el, with iteration numbers
  // starting at start and ending at end
  fillInEmptyIterations: function(el, start, end) {
    var missing_range = _.range(parseInt(start) + 1, parseInt(end));
    console.debug(missing_range);
    _.each(missing_range, function(missing_iteration_number) {
      el.append('<div class="iteration">' + missing_iteration_number + '<span class="points">0 points</span></div>');
    });
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
  }
});
