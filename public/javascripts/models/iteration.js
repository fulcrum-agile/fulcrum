var Iteration = Backbone.Model.extend({

  name: 'iteration',

  initialize: function(opts) {
    this.set({'stories': opts.stories || []});
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

  // Returns the number of points available before this iteration is full.
  // Only valid for backlog iterations.
  availablePoints: function() {
    return this.get('maximum_points') - this.points();
  },

  //
  // Returns true if this iteration has enough points free for a given
  // story.  Only valid for backlog iterations.
  canTakeStory: function(story) {
    if (this.points() === 0) {
      return true;
    }

    if (story.get('story_type') === 'feature') {
      return story.get('estimate') <= this.availablePoints();
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
  }

});
