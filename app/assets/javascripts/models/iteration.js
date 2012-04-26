if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.Iteration = Backbone.Model.extend({

  name: 'iteration',

  initialize: function(opts) {
    this.set({'stories': opts.stories || []});
    this.isFull = false;
  },

  // Return the list of stories
  stories: function() {
    if (this.get('column') === '#in_progress') {
      var stories = this.storiesWithState('accepted');
      return stories.concat(this.storiesExceptState('accepted'));
    } else {
      return this.get('stories');
    }
  },

  storiesWithState: function(state) {
    return _.select(this.get('stories'), function(story) {
      return (story.get('state') === state);
    });
  },

  storiesExceptState: function(state) {
    return _.reject(this.get('stories'), function(story) {
      return (story.get('state') === state);
    });
  },

  points: function() {
    return _.reduce(this.get('stories'), function(memo, story) {
      var estimate = 0;
      if (story.get('story_type') === 'feature') {
        estimate = story.get('estimate') || 0;
      }
      return memo + estimate;
    }, 0);
  },

  acceptedPoints: function() {
    return _.reduce(this.get('stories'), function(memo, story) {
      var estimate = 0;
      if (story.get('story_type') === 'feature' && story.get('state') === 'accepted') {
        estimate = story.get('estimate') || 0;
      }
      return memo + estimate;
    }, 0);
  },

  // Returns the number of points available before this iteration is full.
  // Only valid for backlog iterations.
  availablePoints: function() {
    return this.get('maximum_points') - this.points();
  },

  //
  // Returns true if this iteration has enough points free for a given
  // story.  Only valid for backlog iterations.
  canTakeStory: function(story) {

    if (this.isFull === true) {
      return false;
    }

    if (this.points() === 0) {
      return true;
    }

    if (story.get('story_type') === 'feature') {
      this.isFull = story.get('estimate') > this.availablePoints();
      return !this.isFull;
    } else {
      return true;
    }
  },

  // Report how many points this iteration overflows by.  For example, if
  // the iteration maximum points is 2, and it has a single 5 point story,
  // its overflow will be 3 points.  Will return 0 if the iteration has
  // less than or equal to its maximum points.
  overflowsBy: function() {
    var difference = this.points() - this.get('maximum_points');
    return (difference < 0) ? 0 : difference;
  },

  startDate: function() {
    return this.project.getDateForIterationNumber(this.get('number'));
  }

},{

  //
  // Class properties
  //

  // Creates a range of empty iteration between 2 other iteration objects.
  // For example, if passed iteration 1 for start and iteration 5 for end
  // will return an array of iterations numbered 2, 3 and 4.  Each iteration
  // will be assigned to the provided column.
  createMissingIterations: function(column, startIteration, endIteration) {

    // A reference to Iteration().
    var that = this;

    if (typeof startIteration == "undefined") {
      // Create a dummy iteration with number 0
      startIteration = new that({'number': 0, 'column': column});
    }

    var start = parseInt(startIteration.get('number'), 10) + 1;
    var end = parseInt(endIteration.get('number'), 10);

    if (end < start) {
      throw "end iteration number:" + end + " must be greater than start iteration number:" + start ;
    }

    var missing_range = _.range(start, end);

    return _.map(missing_range, function(missing_iteration_number) {
      var iteration = new that({
        'number': missing_iteration_number, 'column': column
      });
      return iteration;
    });

  }

});
