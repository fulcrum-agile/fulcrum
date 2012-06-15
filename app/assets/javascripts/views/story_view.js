if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.StoryView = Fulcrum.FormView.extend({

  template: JST['templates/story'],

  tagName: 'div',

  initialize: function() {
    _.bindAll(this, "render", "highlight", "moveColumn", "setClassName",
      "transition", "estimate", "disableForm", "renderNotes",
      "renderNotesCollection", "addEmptyNote");

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
    this.model.bind("change:state", this.setClassName);

    this.model.bind("change:notes", this.addEmptyNote);
    this.model.bind("change:notes", this.renderNotesCollection);

    this.model.bind("render", this.hoverBox());
    // Supply the model with a reference to it's own view object, so it can
    // remove itself from the page when destroy() gets called.
    this.model.view = this;

    if (this.model.id) {
      this.id = this.el.id = this.model.id;
    }

    // Set up CSS classes for the view
    this.setClassName();

    // Add an empty note to the collection
    this.addEmptyNote();
  },

  events: {
    "click a.expand": "startEdit",
    "click a.collapse": "saveEdit",
    "click #submit": "saveEdit",
    "click #cancel": "cancelEdit",
    "click .transition": "transition",
    "click input.estimate": "estimate",
    "click #destroy": "clear",
    "click #edit-description": "editDescription",
    "sortupdate": "sortUpdate"
  },

  // Triggered whenever a story is dropped to a new position
  sortUpdate: function(ev, ui) {

    // The target element, i.e. the StoryView.el element
    var target = $(ev.target);

    // Initially, try and get the id's of the previous and / or next stories
    // by just searching up above and below in the DOM of the column position
    // the story was dropped on.  The case where the column is empty is
    // handled below.
    var previous_story_id = target.prev('.story').attr('id');
    var next_story_id = target.next('.story').attr('id');

    // Set the story state if drop column is chilly_bin or backlog
    var column = target.parent().attr('id');
    if (column === 'backlog' || (column === 'in_progress' && this.model.get('state') === 'unscheduled')) {
      this.model.set({state: 'unstarted'});
    } else if (column == 'chilly_bin') {
      this.model.set({state: 'unscheduled'});
    }

    // If both of these are unset, the story has been dropped on an empty
    // column, which will be either the backlog or the chilly bin as these
    // are the only columns that can receive drops from other columns.
    if (typeof previous_story_id == 'undefined' && typeof next_story_id == 'undefined') {

      var beforeSearchColumns = this.model.collection.project.columnsBefore('#' + column);
      var afterSearchColumns  = this.model.collection.project.columnsAfter('#' + column);

      var previousStory = _.last(this.model.collection.columns(beforeSearchColumns));
      var nextStory = _.first(this.model.collection.columns(afterSearchColumns));

      if (typeof previousStory != 'undefined') {
        previous_story_id = previousStory.id;
      }
      if (typeof nextStory != 'undefined') {
        next_story_id = nextStory.id;
      }
    }

    if (typeof previous_story_id != 'undefined') {
      this.model.moveAfter(previous_story_id);
    } else if (typeof next_story_id != 'undefined') {
      this.model.moveBefore(next_story_id);
    } else {
      // The only possible scenario that we should reach this point under
      // is if there is only one story in the collection, so there is no
      // previous or next story.  If this is not the case then something
      // has gone wrong.
      if (this.model.collection.length != 1) {
        throw "Unable to determine previous or next story id for dropped story";
      }
    }
    this.model.save();
  },

  transition: function(ev) {
    // The name of the function that needs to be called on the model is the
    // value of the form button that was clicked.
    var transitionEvent = ev.target.value;

    this.saveInProgress = true;
    this.render();

    this.model[transitionEvent]({silent:true});

    var that = this;
    this.model.save(null, {
      success: function(model, response) {
        that.saveInProgress = false;
        that.render();
      },
      error: function(model, response) {
        var json = $.parseJSON(response.responseText);
        window.projectView.notice({title: "Save error", text: model.errorMessages()});
        that.saveInProgress = false;
        that.render();
      }
    });
  },

  estimate: function(ev) {
    this.saveInProgress = true;
    this.render();
    this.model.set({estimate: ev.target.value});

    var that = this;
    this.model.save(null, {
      success: function(model, response) {
        that.saveInProgress = false;
        that.render();
      },
      error: function(model, response) {
        var json = $.parseJSON(response.responseText);
        window.projectView.notice({title: "Save error", text: model.errorMessages()});
        that.saveInProgress = false;
        that.render();
      }
    });
  },

  // Move the story to a new column
  moveColumn: function() {
    this.$el.appendTo(this.model.get('column'));
  },

  startEdit: function() {
    this.model.set({editing: true, editingDescription: false});
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
    this.disableForm();

    // Call this here to ensure the story gets it's accepted_at date set
    // before the story collection callbacks are run if required.  The
    // collection callbacks need this to be set to know which iteration to
    // put an accepted story in.
    this.model.setAcceptedAt();

    var that = this;
    this.model.save(null, {
      success: function(model, response) {
        that.model.set({editing: false});
        that.enableForm();
      },
      error: function(model, response) {
        var json = $.parseJSON(response.responseText);
        model.set({editing: true, errors: json.story.errors});
        window.projectView.notice({title: "Save error", text: model.errorMessages()});
        that.enableForm();
      }
    });
  },

  // Delete the story and remove it's view element
  clear: function() {
    this.model.clear();
  },

  editDescription: function() {
    this.model.set({editingDescription: true});
    this.render();
  },

  // Visually highlight the story if an external change happens
  highlight: function() {
    if(!this.model.get('editing')) {
      // Workaround for http://bugs.jqueryui.com/ticket/5506
      if (this.$el.is(':visible')) {
        this.$el.effect("highlight", {}, 3000);
      }
    }
  },

  render: function() {
    if(this.model.get('editing') === true) {

      this.$el.empty();
      this.$el.addClass('editing');

      this.$el.append(
        this.makeFormControl(function(div) {
          if (!this.model.isNew()) {
            $(div).append(
              this.make("a", {'class': "collapse icon icon-chevron-down"})
            );
          }
          $(div).append(this.textField("title", {'placeholder': 'Story title'}));
        })
      );

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).append(this.submit());
          if (!this.model.isNew()) {
            $(div).append(this.destroy());
          }
          $(div).append(this.cancel());
        })
      );



      this.$el.append(
        this.makeFormControl({
          name: "estimate",
          label: "Estimate",
          control: this.select("estimate", this.model.point_values(), {blank: 'No estimate'})
        })
      );

      this.$el.append(
        this.makeFormControl({
          name: "story_type",
          label: "Story Type",
          control: this.select("story_type", ["feature", "chore", "bug", "release"])
        })
      );

      this.$el.append(
        this.makeFormControl({
          name: "state",
          label: "State",
          control: this.select("state", ["unscheduled", "unstarted", "started", "finished", "delivered", "accepted", "rejected"])
        })
      );

      this.$el.append(
        this.makeFormControl({
          name: "requested_by_id",
          label: "Requested By",
          control: this.select("requested_by_id",
            this.model.collection.project.users.forSelect(),{blank: '---'})
        })
      );

      this.$el.append(
        this.makeFormControl({
          name: "owned_by_id",
          label: "Owned By",
          control: this.select("owned_by_id",
            this.model.collection.project.users.forSelect(),{blank: '---'})
        })
      );

      this.$el.append(
        this.makeFormControl({
          name: "labels",
          label: "Labels",
          control: this.textField("labels")
        })
      );



      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).before(this.label("description", "Description"));
          if(this.model.isNew() || this.model.get('editingDescription')) {
            $(div).append(this.textArea("description"));
          } else {
            var description = this.make('div');
            $(description).addClass('description');
            $(description).html(
              window.md.makeHtml(this.model.escape('description'))
            );
            $(div).append(description);
            $(description).after('<input id="edit-description" type="button" class="btn btn-mini" value="Edit"/>');
          }
        })
      );

      this.initTags();

      this.renderNotes();

    } else {
      this.$el.removeClass('editing');
      this.$el.html(this.template({story: this.model, view: this}));
    }
    this.hoverBox();
    return this;
  },

  setClassName: function() {
    var className = [
      'story', 'form-horizontal', this.model.get('story_type'), this.model.get('state')
    ].join(' ');
    if (this.model.estimable() && !this.model.estimated()) {
      className += ' unestimated';
    }
    this.className = this.el.className = className;
    return this;
  },

  saveInProgress: false,

  disableForm: function() {
    this.$el.find('input,select,textarea').attr('disabled', 'disabled');
    this.$el.find('a.collapse,a.expand').removeClass(/icon-/).addClass('icon-throbber');
  },

  enableForm: function() {
    this.$el.find('a.collapse').removeClass(/icon-/).addClass("icon-chevron-down");
  },

  initTags: function() {
    var model = this.model;
    var $input = this.$el.find("input[name='labels']");
    $input.tagit({
      availableTags: model.collection.labels
    });

    // Manually bind labels for now
    $input.bind('change', function(){
      model.set({ labels: $(this).val()});
    });
  },

  renderNotes: function() {
    if (this.model.notes.length > 0) {
      var el = this.$el;
      el.append('<hr/>');
      el.append('<h3>Notes</h3>');
      el.append('<div class="notelist"/>');
      this.renderNotesCollection();
    }
  },

  renderNotesCollection: function() {
    var notelist = this.$('div.notelist');
    notelist.html('');
    this.addEmptyNote();
    this.model.notes.each(function(note) {
      var view;
      if (note.isNew()) {
        view = new Fulcrum.NoteForm({model: note});
      } else {
        view = new Fulcrum.NoteView({model: note});
      }
      notelist.append(view.render().el);
    });
  },

  addEmptyNote: function() {

    // Don't add an empty note if the story is unsaved.
    if (this.model.isNew()) {
      return;
    }

    // Don't add an empty note if the notes collection already has a trailing
    // new Note.
    var last = this.model.notes.last();
    if (last && last.isNew()) {
      return;
    }

    // Add a new unsaved note to the collection.  This will be rendered
    // as a form which will allow the user to add a new note to the story.
    this.model.notes.add();
    this.$el.find('a.collapse,a.expand').removeClass(/icon-/).addClass('icon-throbber');
  },

  // FIXME Move to separate view
  hoverBox: function(){
    var view  = this;
    this.$el.find('.popover-activate').popover({
      title: function(){
        return view.model.get("title");
      },
      content: function(){
        return JST['templates/story_hover']({story: view.model});
      },
      // A small delay to stop the popovers triggering whenever the mouse is
      // moving around
      delayIn: 200,
      placement: view.hoverBoxPlacement,
      html: true,
      live: true
    });
  },

  hoverBoxPlacement: function(box, trigger) {
    // Gets called from a jQuery context, so this is set to the element that
    // the popover is bound to.
    var position = $(trigger).position();
    var windowWidth = $(window).width();
    // If the element is to the right of the vertical half way line in the
    // viewport, position the popover on the left.
    if (position.left > (windowWidth / 2)) {
      return 'left';
    }
    return 'right';
  },

  initTags: function() {
    var model = this.model;
    var $input = this.$el.find("input[name='labels']");
    $input.tagit({
      availableTags: model.collection.labels
    });

    // Manually bind labels for now
    $input.bind('change', function(){
      model.set({ labels: $(this).val()});
    });
  },

  setFocus: function() {
    if (this.model.get('editing') === true ) {
      this.$('input').first().focus();
    }
  },

  makeFormControl: function(content) {
    var div             = this.make('div', {'class': 'control-group'});
    var controlWrapper  = this.make('div', {'class': 'controls'});
    var $div            = $(div);
    var $controlWrapper = $(controlWrapper);
    $div.append(controlWrapper);
    if (typeof content == 'function') {
      $div.addClass('unlabelled');
      content.call(this, controlWrapper);
    } else if (typeof content == 'object') {
      $div.addClass(content.name || 'unlabelled');
      if (content.label) {
        $div.prepend(this.label(content.name, content.label));
      }
      $controlWrapper.append(content.control);
    }
    return div;
  }
});
