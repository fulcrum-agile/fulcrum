var StoryView = FormView.extend({

  tagName: 'div',

  initialize: function() {
    _.bindAll(this, "render", "highlight", "moveColumn", "setClassName");

    // Rerender on any relevant change to the views story
    this.model.bind("change", this.render);

    this.model.bind("change:title", this.highlight);
    this.model.bind("change:description", this.highlight);
    this.model.bind("change:column", this.highlight);
    this.model.bind("change:state", this.highlight);
    this.model.bind("change:position", this.highlight);
    this.model.bind("change:estimate", this.highlight);
    this.model.bind("change:story_type", this.highlight);

    this.model.bind("change:column", this.moveColumn);

    this.model.bind("change:estimate", this.setClassName);

    // Supply the model with a reference to it's own view object, so it can
    // remove itself from the page when destroy() gets called.
    this.model.view = this;

    if (this.model.id) {
      this.id = this.el.id = this.model.id;
    }

    // Set up CSS classes for the view
    this.setClassName();
  },

  events: {
    "click img.expand": "startEdit",
    "click img.collapse": "saveEdit",
    "click #submit": "saveEdit",
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

    // If the model was edited, but the edits were deemed invalid by the
    // server, the local copy of the model will still be invalid and have
    // errors set on it after cancel.  So, reload it from the server, which
    // will return the attributes to their true state.
    if (this.model.hasErrors()) {
      this.model.unset('errors');
      this.model.fetch();
    }

    // If this is a new story and cancel is clicked, the story and view
    // should be removed.
    if (this.model.isNew()) {
      this.model.clear();
    }
  },

  saveEdit: function() {
    this.model.set(this.changed_attributes);
    var that = this;
    this.model.save(null, {
      success: function(model, response) {
        that.model.set({editing: false});
      },
      error: function(model, response) {
        var json = $.parseJSON(response.responseText);
        model.set({editing: true, errors: json.story.errors});
        App.notice({title: "Save error", text: model.errorMessages()});
      }
    });
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
      if (!this.model.isNew()) {
        $(div).append(
          this.make("img", {class: "collapse", src: "/images/collapse.png"})
        );
      }
      $(div).append(this.textField("title"));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.submit());
      if (!this.model.isNew()) $(div).append(this.destroy());
      $(div).append(this.cancel());
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("estimate", "Estimate"));
      $(div).append('<br/>');

      $(div).append(this.select("estimate", this.model.point_values(), {blank: 'No estimate'}));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("story_type", "Story Type"));
      $(div).append('<br/>');
      $(div).append(this.select("story_type", ["feature", "chore", "bug", "release"]));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("state", "State"));
      $(div).append('<br/>');
      $(div).append(this.select("state", ["unscheduled", "unstarted", "started", "finished", "delivered", "accepted", "rejected"]));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("requested_by_id", "Requested By"));
      $(div).append('<br/>');
      $(div).append(this.select("requested_by_id",
        this.model.collection.project.users.forSelect(),{blank: '---'}));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("owned_by_id", "Owned By"));
      $(div).append('<br/>');
      $(div).append(this.select("owned_by_id",
        this.model.collection.project.users.forSelect(),{blank: '---'}));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("description", "Description"));
      $(div).append('<br/>');
      $(div).append(this.textArea("description"));
      $(this.el).append(div);

    } else {
      $(this.el).html($('#story_tmpl').tmpl(this.model.toJSON(), {story: this.model}));
    }
    return this;
  },

  setClassName: function() {
    var className = 'story ' + this.model.get('story_type');
    if (this.model.estimable() && !this.model.estimated()) {
      className += ' unestimated';
    }
    this.className = this.el.className = className;
    return this;
  }
});
