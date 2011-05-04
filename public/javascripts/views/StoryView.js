var StoryView = FormView.extend({

  tagName: 'div',

  initialize: function() {
    _.bindAll(this, "render", "highlight", "moveColumn");

    // Rerender on any relevant change to the views story
    this.model.bind("change", this.render);

    // TODO - Only highlight on relevant attribute changes
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
