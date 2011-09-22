var AppView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, 'addOne', 'addAll', 'render');

    window.Project.stories.bind('add', this.addOne);
    window.Project.stories.bind('reset', this.addAll);
    window.Project.stories.bind('all', this.render);

    window.Project.stories.fetch();
  },

  addOne: function(story, column) {
    // If column is blank determine it from the story.  When the add event
    // is bound on a collection, the callback send the collection as the
    // second argument, so also check that column is a string and not an
    // object for those cases.
    if (typeof column === 'undefined' || typeof column !== 'string') {
      column = story.column();
    }
    var view = new StoryView({model: story});
    $(column).append(view.render().el);
  },

  addAll: function() {
    $('#done').html("");
    $('#in_progress').html("");
    $('#backlog').html("");
    $('#chilly_bin').html("");

    //
    // Done column
    //
    var that = this;
    var done_iterations = _.groupBy(window.Project.stories.column('#done'),
                                    function(story) {
                                      return story.iterationNumber();
                                    });

    // There will sometimes be gaps in the done iterations, i.e. no work
    // may have been accepted in a given iteration, and it will therefore
    // not appear in the set.  Store this to iterate over those gaps and
    // insert empty iterations.
    var last_iteration = new Iteration({'number': 0});

    _.each(done_iterations, function(stories, iterationNumber) {

      var iteration = new Iteration({
        'number': iterationNumber, 'stories': stories, column: '#done'
      });

      window.Project.iterations.push(iteration);

      that.fillInEmptyIterations('#done', last_iteration, iteration);
      last_iteration = iteration;

      $('#done').append(that.iterationDiv(iteration));
      _.each(stories, function(story) {that.addOne(story)});
    });

    // Fill in any remaining empty iterations in the done column
    var currentIteration = new Iteration({
      'number': window.Project.currentIterationNumber(),
      'stories': window.Project.stories.column('#in_progress'),
      'maximum_points': window.Project.velocity()
    });
    this.fillInEmptyIterations('#done', last_iteration, currentIteration);

    //
    // In progress column
    //
    // FIXME - Show completed/total points
    $('#in_progress').append(that.iterationDiv(currentIteration));
    _.each(window.Project.stories.column('#in_progress'), function(story) {
      that.addOne(story);
    });



    //
    // Backlog column
    //
    var backlogIteration = new Iteration({
      'number': currentIteration.get('number') + 1,
      'rendered': false,
      'maximum_points': window.Project.velocity()
    });
    _.each(window.Project.stories.column('#backlog'), function(story) {

      if (currentIteration.canTakeStory(story)) {
        currentIteration.get('stories').push(story);
        that.addOne(story, '#in_progress');
        return;
      }

      if (!backlogIteration.canTakeStory(story)) {
        // The iteration is full, render it
        $('#backlog').append(that.iterationDiv(backlogIteration));
        _.each(backlogIteration.get('stories'), function(iterationStory) {
          that.addOne(iterationStory);
        });
        backlogIteration.set({'rendered': true});

        var nextNumber = backlogIteration.get('number') + 1 + Math.ceil(backlogIteration.overflowsBy() / window.Project.velocity());

        var nextIteration = new Iteration({
          'number': nextNumber,
          'rendered': false,
          'maximum_points': window.Project.velocity()
        });

        // If the iteration overflowed, create enough empty iterations to
        // accommodate the surplus.  For example, if the project velocity
        // is 1, and the last iteration contained 1 5 point story, we'll
        // need 4 empty iterations.
        //
        that.fillInEmptyIterations('#backlog', backlogIteration, nextIteration);
        backlogIteration = nextIteration;
      }

      backlogIteration.get('stories').push(story);
      //that.addOne(story);
    });

    // Render the backlog final backlog iteration if it isn't already
    $('#backlog').append(that.iterationDiv(backlogIteration));
    _.each(backlogIteration.get('stories'), function(story) {
      that.addOne(story);
    });
    backlogIteration.set({'rendered': true});

    _.each(window.Project.stories.column('#chilly_bin'), function(story) {
      that.addOne(story)
    });
  },

  // Creates a set of empty iterations in column, with iteration numbers
  // starting at start and ending at end
  fillInEmptyIterations: function(column, start, end) {
    var el = $(column);
    var missing_range = _.range(
      parseInt(start.get('number')) + 1,
      parseInt(end.get('number'))
    );
    var that = this;
    _.each(missing_range, function(missing_iteration_number) {
      var iteration = new Iteration({
        'number': missing_iteration_number, 'column': column
      });
      window.Project.iterations.push(iteration);
      el.append(that.iterationDiv(iteration));
    });
  },

  scaleToViewport: function() {
    var storyTableTop = $('table.stories tbody').offset().top;
    // Extra for the bottom padding and the 
    var extra = 100;
    var height = $(window).height() - (storyTableTop + extra);
    $('.storycolumn').css('height', height + 'px');
  },

  // FIXME - Make a view
  iterationDiv: function(iteration) {
    // FIXME Make a model method
    var iteration_date = window.Project.getDateForIterationNumber(iteration.get('number'));
    var points_markup = '<span class="points">' + iteration.points() + ' points</span>';
    return '<div class="iteration">' + iteration.get('number') + ' - ' + iteration_date.toDateString() + points_markup + '</div>'
  },

  notice: function(message) {
    $.gritter.add(message);
  }
});
