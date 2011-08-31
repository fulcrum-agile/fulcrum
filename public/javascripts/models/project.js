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

    this.iterations = [];
  },

  defaults: {
    default_velocity: 10
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
  },

  milliseconds_in_a_day: 1000 * 60 * 60 * 24,

  // Return the correct iteration number for a given date.
  getIterationNumberForDate: function(compare_date) {
    //var start_date = new Date(this.get('start_date'));
    var start_date = this.startDate();
    var difference = Math.abs(compare_date.getTime() - start_date.getTime());
    var days_apart = Math.round(difference / this.milliseconds_in_a_day);
    return Math.floor((days_apart / (this.get('iteration_length') * 7)) + 1);
  },

  getDateForIterationNumber: function(iteration_number) {
    // The difference betweeen the start date in days.  Iteration length is
    // in weeks.
    var difference = (7 * this.get('iteration_length')) * (iteration_number - 1);
    var start_date = this.startDate();
    var iteration_date = new Date(start_date);

    iteration_date.setDate(start_date.getDate() + difference);
    return iteration_date;
  },

  currentIterationNumber: function() {
    return this.getIterationNumberForDate(new Date());
  },

  startDate: function() {

    var start_date;
    if (this.get('start_date')) {
      start_date = new Date(this.get('start_date'));
    } else {
      start_date = new Date();
    }

    // Is the specified project start date the same week day as the iteration
    // start day?
    if (start_date.getDay() === this.get('iteration_start_day')) {
      return start_date;
    } else {
      // Calculate the date of the nearest prior iteration start day to the
      // specified project start date.  So if the iteration start day is
      // set to Monday, but the project start date is set to a specific
      // Thursday, return the Monday before the Thursday.  A greater
      // mathemtician than I could probably do this with the modulo.
      var day_difference = start_date.getDay() - this.get('iteration_start_day');

      // The iteration start day is after the project start date, in terms of
      // day number
      if (day_difference < 0) {
        day_difference = day_difference + 7;
      }
      return new Date(start_date - day_difference * this.milliseconds_in_a_day);
    }
  },

  velocity: function() {
    if (this.doneIterations().length === 0) {
      return this.get('default_velocity');
    } else {
      // TODO Make number of iterations configurable
      var numIterations = 3;
      var iterations = this.doneIterations();
      
      // Take a maximum of numIterations from the end of the array
      if (iterations.length > numIterations) {
        iterations = iterations.slice(iterations.length - numIterations);
      }

      var pointsArray = _.invoke(iterations, 'points');
      var sum = _.reduce(pointsArray, function(memo, points) {
        return memo + points;
      }, 0);
      var velocity = Math.floor(sum / pointsArray.length);
      return velocity < 1 ? 1 : velocity;
    }
  },

  doneIterations: function() {
    return _.select(this.iterations, function(iteration) {
      return iteration.get('column') === "#done";
    });
  }
});
