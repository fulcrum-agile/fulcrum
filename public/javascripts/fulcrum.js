// Backbone implementation

var Story = Backbone.Model.extend({
  name: 'story',

  moveBetween: function(before, after) {
    var beforeStory = this.collection.get(before);
    var afterStory = this.collection.get(after);
    var difference = (afterStory.position() - beforeStory.position()) / 2;
    var newPosition = difference + beforeStory.position();
    this.set({position: newPosition});
    this.collection.sort({silent: true});
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
    this.collection.sort({silent: true});
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
    state: "unscheduled",
    column: "#chilly_bin",
    story_type: "feature"
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

var StoryCollection = Backbone.Collection.extend({
  model: Story,

  comparator: function(story) {
    return story.position();
  },

  next: function(story) {
    return this.at(this.indexOf(story) + 1);
  },

  previous: function(story) {
    return this.at(this.indexOf(story) - 1);
  }
});

var Project = Backbone.Model.extend({
  name: 'project',

  initialize: function() {
    this.stories = new StoryCollection;
    this.stories.url = this.url() + '/stories';
  },

  url: function() {
    return '/projects/' + this.id;
  },
});

var StoryView = FormView.extend({

  tagName: 'div',

  initialize: function() {
    _.bindAll(this, "render", "highlight", "moveColumn");
    // Rerender on any change to the views story
    this.model.bind("change", this.render);
    this.model.bind("change", this.highlight);
    this.model.bind("change:column", this.moveColumn);

    // Supply the model with a reference to it's own view object, so it can
    // remove itself from the page when destroy() gets called.
    this.model.view = this;
  },

  events: {
    "click img.expand": "startEdit",
    "click img.collapse": "cancelEdit",
    "click #submit": "modelSave",
    "click #cancel": "cancelEdit",
    "click .transition": "transition",
    "click input.estimate": "estimate",
    "click #destroy": "clear",
    "sortupdate": "sortUpdate"
  },

  // Triggered whenever a story is dropped to a new position
  sortUpdate: function(ev, ui) {
    var previous_story_id = $(ev.target).prev().attr('id');
    var next_story_id = $(ev.target).next().attr('id');
    if (typeof previous_story_id != 'undefined') {
      this.model.moveAfter(previous_story_id);
    } else if (typeof next_story_id != 'undefined') {
      this.model.moveBefore(next_story_id);
    } else {
      // TODO Implement dropping on empty columns
      throw "Dropping on empty columns is not yet implemented";
    }

    //this.model.moveBetween(previous_story_id, next_story_id);
    this.model.save();
  },

  transition: function(ev) {
    // The name of the function that needs to be called on the model is the
    // value of the form button that was clicked.
    var transitionEvent = ev.target.value;
    this.model[transitionEvent]();
    this.model.save();
  },

  estimate: function(ev) {
    this.model.set({estimate: ev.target.value});
    this.model.save();
  },

  // Move the story to a new column
  moveColumn: function() {
    $(this.el).appendTo(this.model.get('column'));
  },

  startEdit: function() {
    this.model.set({editing: true});
  },

  cancelEdit: function() {
    this.model.set({editing: false});
  },

  modelSave: function() {
    this.model.save();
    this.model.set({editing: false});
  },

  // Delete the story and remove it's view element
  clear: function() {
    this.model.clear();
  },

  // Visually highlight the story if an external change happens
  highlight: function() {
    if(!this.model.get('editing')) {
      $(this.el).effect("highlight", {}, 3000);
    }
  },

  render: function() {
    if(this.model.get('editing') === true) {
      $(this.el).empty();
      div = this.make('div');
      $(div).append(this.make("img", {class: "collapse", src: "/images/collapse.png"}));
      $(div).append(this.textField("title"));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.submit());
      $(div).append(this.destroy());
      $(div).append(this.cancel());
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("estimate"));
      $(div).append('<br/>');
      // TODO Make dynamic
      $(div).append(this.select("estimate", [["zero","0"],1,2,3,5,8]));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("story_type"));
      $(div).append('<br/>');
      $(div).append(this.select("story_type", ["feature", "chore", "bug", "release"]));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("state"));
      $(div).append('<br/>');
      $(div).append(this.select("state", ["unscheduled", "unstarted", "started", "finished", "delivered", "accepted", "rejected"]));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("description"));
      $(div).append('<br/>');
      $(div).append(this.textArea("description"));
      $(this.el).append(div);

    } else {
      $(this.el).html($('#story_tmpl').tmpl(this.model.toJSON()));
    }
    return this;
  }
});

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
    $(story.get('column')).append(view.render().el);
  },

  addAll: function() {
    window.Project.stories.each(this.addOne);
  },

  scaleToViewport: function() {
    // TODO Make this a calculated value
    var height = $(window).height() - 250;
    $('.storycolumn').css('height', height + 'px');
  }
});

$(function() {
  $('#add_story').click(function() {
    window.Project.stories.add([{
      title: "New story", events: [], editing: true
    }]);
  });

  $('div.sortable').sortable({
    handle: '.story-title', opacity: 0.6,
    update: function(ev, ui) {
      ui.item.trigger("sortupdate", ev, ui);
    }
    //receive: function(ev, ui) {
    //  ui.item.trigger("sortreceive", ev, ui);
    //}
  });

  //$('#backlog').sortable('option', 'connectWith', '#chilly_bin');
  //$('#chilly_bin').sortable('option', 'connectWith', '#backlog');
});
