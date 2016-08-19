var NoteCollection = require('collections/note_collection');
var TaskCollection = require('collections/task_collection');
var SharedModelMethods = require('mixins/shared_model_methods');

var Story = module.exports = Backbone.Model.extend({
  name: 'story',

  i18nScope: 'activerecord.attributes.story',

  timestampFormat: 'd mmm yyyy, h:MMtt',

  isReadonly: false,

  initialize: function(args) {
    _.bindAll(this, 'changeState', 'populateNotes', 'populateTasks');

    this.views = [];
    this.clickFromSearchResult = false;

    this.on('change:state', this.changeState);
    this.on('change:notes', this.populateNotes);
    this.on('change:tasks', this.populateTasks);

    // FIXME Call super()?
    this.maybeUnwrap(args);

    this.initNotes();
    this.initTasks();
    this.setColumn();

    this.setReadonly();
  },

  setReadonly: function() {
    if(this.get('state') === 'accepted' && this.get('accepted_at') !== undefined)
      this.isReadonly = true;
  },

  changeState: function(model, new_value) {
    if (new_value == "started" && !this.get('owned_by_id')) {
      model.set({owned_by_id: model.collection.project.current_user.id}, true);
    }

    model.setAcceptedAt();
    model.setColumn();
  },

  moveBetween: function(before, after) {
    var beforeStory = this.collection.get(before);
    var afterStory = this.collection.get(after);
    var difference = (afterStory.position() - beforeStory.position()) / 2;
    var newPosition = difference + beforeStory.position();
    this.set({position: newPosition});
    this.collection.sort();
    return this;
  },

  moveAfter: function(beforeId) {
    var before = this.collection.get(beforeId);
    var after = this.collection.next(before);
    if (typeof after == 'undefined') {
      afterPosition = before.position() + 2;
    } else {
      afterPosition = after.position();
    }
    var difference = (afterPosition - before.position()) / 2;
    var newPosition = difference + before.position();

    this.set({position: newPosition});
    return this;
  },

  moveBefore: function(afterId) {
    var after = this.collection.get(afterId);
    var before = this.collection.previous(after);
    if (typeof before == 'undefined') {
      beforePosition = 0.0;
    } else {
      beforePosition = before.position();
    }
    var difference = (after.position() - beforePosition) / 2;
    var newPosition = difference + beforePosition;

    this.set({position: newPosition});
    this.collection.sort({silent: true});
    return this;
  },

  defaults: {
    events: [],
    documents: [],
    state: "unscheduled",
    story_type: "feature"
  },

  setColumn: function() {

    var column = '#in_progress';

    switch(this.get('state')) {
      case 'unscheduled':
        column = '#chilly_bin';
        break;
      case 'unstarted':
        column = '#backlog';
        break;
      case 'accepted':
        // Accepted stories remain in the in progress column if they were
        // completed within the current iteration.
        if (this.collection.project.currentIterationNumber() === this.iterationNumber()) {
          column = '#in_progress';
        } else {
          column = '#done';
        }
        break;
    }

    this.column = column;
  },

  clear: function() {
    this.destroy();
    _.each(this.views, function(view) {
      view.remove();
    });
  },

  estimable: function() {
    if (this.get('story_type') === 'feature') {
      return !this.estimated();
    } else {
      return false;
    }
  },

  estimated: function() {
    var estimate = this.get('estimate');
    return !(_.isUndefined(estimate) || _.isNull(estimate));
  },

  notEstimable: function () {
    var storyType = this.get('story_type');
    return (storyType !== 'feature' && storyType !== 'release');
  },

  point_values: function() {
    return this.collection.project.get('point_values');
  },

  // List available state transitions for this story
  events: function() {
    switch (this.get('state')) {
      case 'started':
        return ["finish"];
        break;
      case 'finished':
        return ["deliver"];
        break;
      case 'delivered':
        return ["accept", "reject"];
        break;
      case 'rejected':
        return ["restart"];
        break;
      case 'accepted':
        return [];
        break;
      default:
        return ["start"];
    }
  },

  // State machine transitions
  start: function() {
    this.set({state: "started"});
  },

  finish: function() {
    this.set({state: "finished"});
  },

  deliver: function() {
    this.set({state: "delivered"});
  },

  accept: function() {
    this.set({state: "accepted"});
  },

  reject: function() {
    this.set({state: "rejected"});
  },

  restart: function() {
    this.set({state: "started"});
  },

  position: function() {
    return parseFloat(this.get('position'));
  },

  className: function() {
    var className = 'story ' + this.get('story_type');
    if (this.estimable() && !this.estimated()) {
      className += ' unestimated';
    }
    return className;
  },

  // Returns the user that owns this Story, or undefined if no user owns
  // the Story
  owned_by: function() {
    return this.collection.project.users.get(this.get('owned_by_id'));
  },

  requested_by: function() {
    return this.collection.project.users.get(this.get('requested_by_id'));
  },

  created_at: function() {
    var d = new Date(this.get('created_at'));
    return d.format(this.timestampFormat);
  },

  hasDetails: function() {
    return (_.isString(this.get('description')) || this.hasNotes());
  },

  iterationNumber: function() {
    if (this.get('state') === "accepted") {
      return this.collection.project.getIterationNumberForDate(this.acceptedAtBeginningOfDay());
    }
  },

  acceptedAtBeginningOfDay: function() {
    var accepted_at = this.get("accepted_at");
    if (!_.isUndefined(accepted_at)) {
      accepted_at = new Date(accepted_at);
      accepted_at.setHours(0);
      accepted_at.setMinutes(0);
      accepted_at.setSeconds(0);
      accepted_at.setMilliseconds(0);
    }
    return accepted_at;
  },

  // If the story state is 'accepted', and the 'accepted_at' attribute is not
  // set, set it to today's date.
  setAcceptedAt: function() {
    if (this.get('state') === "accepted" && !this.get('accepted_at')) {
      var today = new Date();
      today.setHours(0);
      today.setMinutes(0);
      today.setSeconds(0);
      today.setMilliseconds(0);
      this.set({accepted_at: today});
    }
  },

  labels: function() {
    if (!_.isString(this.get('labels'))) {
      return [];
    }
    return _.map(this.get('labels').split(','), function(label) {
      return $.trim(label);
    });
  },

  // Initialize the notes collection on this story, and populate if necessary
  initNotes: function() {
    this.notes = new NoteCollection();
    this.notes.story = this;
    this.populateNotes();
  },

  // Resets this stories notes collection
  populateNotes: function() {
    var notes = this.get("notes") || [];
    this.notes.reset(notes);
  },

  // Returns true if any of the story has any saved notes.
  hasNotes: function() {
    return this.notes.any(function(note) {
      return !note.isNew();
    });
  },

  // Initialize the tasks collection on this story, and populate if necessary
  initTasks: function() {
    this.tasks = new TaskCollection();
    this.tasks.story = this;
    this.populateTasks();
  },

  populateTasks: function() {
    var tasks = this.get('tasks') || [];
    this.tasks.reset(tasks);
  },

  sync: function(method, model, options) {
    if( model.isReadonly ) {
      return true;
    }

    var documents = options.documents;

    if(documents && documents.length > 0 && documents.val()) {
      model.set('documents', JSON.parse(documents.val()));
    } else {
      model.set('documents', [{}]);
    }
    Backbone.sync(method, model, options);
  }
});

_.defaults(Story.prototype, SharedModelMethods);
