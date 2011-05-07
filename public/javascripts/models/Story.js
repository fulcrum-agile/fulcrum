var Story = Backbone.Model.extend({
  name: 'story',

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

    if (before.get('state') == 'unstarted' && this.get('state') == 'unscheduled') {
      this.set({state: 'unstarted'});
    }
    if (before.get('state') == 'unscheduled' && this.get('state') == 'unstarted') {
      this.set({state: 'unscheduled'});
    }

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

    if (after.get('state') == 'unstarted' && this.get('state') == 'unscheduled') {
      this.set({state: 'unstarted'});
    }
    if (after.get('state') == 'unscheduled' && this.get('state') == 'unstarted') {
      this.set({state: 'unscheduled'});
    }

    this.set({position: newPosition});
    this.collection.sort({silent: true});
    return this;
  },

  defaults: {
    events: [],
    state: "unscheduled",
    story_type: "feature"
  },

  column: function() {
    switch(this.get('state')) {
      case 'unscheduled':
        return '#chilly_bin';
        break;
      case 'unstarted':
        return '#backlog';
        break;
      case 'accepted':
        return '#done';
        break;
      default:
        return '#in_progress';
        break;
    }
  },

  clear: function() {
    this.destroy();
    this.view.remove();
  },

  estimable: function() {
    return this.get('story_type') === 'feature';
  },

  estimated: function() {
    return typeof this.get('estimate') !== 'undefined';
  },

  point_values: function() {
    return this.collection.project.get('point_values');
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
  }
});
