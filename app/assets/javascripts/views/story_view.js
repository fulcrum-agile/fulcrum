if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.StoryView = Fulcrum.FormView.extend({

  template: JST['templates/story'],

  tagName: 'div',

  initialize: function(options) {
    _.extend(this, _.pick(options, "isSearchResult"));

    _.bindAll(this, "render", "highlight", "moveColumn", "setClassName",
      "transition", "estimate", "disableForm", "renderNotes",
      "renderNotesCollection", "addEmptyNote", "hoverBox");

    // Rerender on any relevant change to the views story
    this.model.on("change", this.render);

    this.model.on("change:title", this.highlight);
    this.model.on("change:description", this.highlight);
    this.model.on("change:column", this.highlight);
    this.model.on("change:state", this.highlight);
    this.model.on("change:position", this.highlight);
    this.model.on("change:estimate", this.highlight);
    this.model.on("change:story_type", this.highlight);

    this.model.on("change:column", this.moveColumn);

    this.model.on("change:estimate", this.setClassName);
    this.model.on("change:state", this.setClassName);

    this.model.on("change:notes", this.addEmptyNote);
    this.model.on("change:notes", this.renderNotesCollection);

    this.model.on("render", this.hoverBox);
    // Supply the model with a reference to it's own view object, so it can
    // remove itself from the page when destroy() gets called.
    this.model.views.push(this);

    if (this.model.id) {
      this.id = this.el.id = (this.isSearchResult ? 'search-result-' : '') + this.model.id;
      this.$el.attr('id', 'story-' + this.id);
      this.$el.data('story-id', this.id);
    }

    // Set up CSS classes for the view
    this.setClassName();

    // Add an empty note to the collection
    this.addEmptyNote();
  },

  events: {
    "click": "startEdit",
    "click .submit": "saveEdit",
    "click .cancel": "cancelEdit",
    "click .transition": "transition",
    "click input.estimate": "estimate",
    "click .destroy": "clear",
    "click .edit-description": "editDescription",
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
    var previous_story_id = target.prev('.story').data('story-id');
    var next_story_id = target.next('.story').data('story-id');

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
    if (_.isUndefined(previous_story_id) && _.isUndefined(next_story_id)) {

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

    if (!_.isUndefined(previous_story_id)) {
      this.model.moveAfter(previous_story_id);
    } else if (!_.isUndefined(next_story_id)) {
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
        window.projectView.notice({
          title: I18n.t("save error"),
          text: model.errorMessages()
        });
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
        window.projectView.notice({
          title: I18n.t("save error"),
          text: model.errorMessages()
        });
        that.saveInProgress = false;
        that.render();
      }
    });
  },

  canEdit: function() {
    var isEditable = this.model.get('editing');
    var isSearchResultContainer = this.$el.hasClass('searchResult');
    var clickFromSearchResult = this.model.get('clickFromSearchResult');
    if ( clickFromSearchResult && isSearchResultContainer ) {
      return isEditable;
    } else if ( !clickFromSearchResult && !isSearchResultContainer ) {
      return isEditable;
    } else {
      return false;
    }
  },

  // Move the story to a new column
  moveColumn: function() {
    this.$el.appendTo(this.model.get('column'));
  },

  startEdit: function(e) {
    console.log(this.$el);
    if (this.eventShouldExpandStory(e)) {
      this.model.set({editing: true, editingDescription: false, clickFromSearchResult: this.$el.hasClass('searchResult')});
      this.removeHoverbox();
    }
  },

  // When a story is clicked, this method is used to check whether the
  // corresponding click event should expand the story into its form view.
  eventShouldExpandStory: function(e) {
    // Shouldn't expand if it's already expanded.
    if (this.canEdit()) {
      return false;
    }
    // Should expand if the click wasn't on one of the buttons.
    return !$(e.target).is('input');
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
        window.projectView.notice({
          title: I18n.t("Save error"),
          text: model.errorMessages()
        });
        that.enableForm();
      }
    });
  },

  // Delete the story and remove it's view element
  clear: function() {
    if (confirm("Are you sure you want to destroy this story?"))
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
    if(this.canEdit()) {

      this.$el.empty();
      this.$el.addClass('editing');

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).addClass('story-controls');
          $(div).append(this.submit());
          if (!this.model.isNew()) {
            $(div).append(this.destroy());
          }
          $(div).append(this.cancel());
        })
      );

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).append(this.textField("title", {
            'class' : 'title form-control',
            'placeholder': I18n.t('story title'),
            'maxlength': 255,
          }));
        })
      );

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).addClass('form-inline');
          $(div).append(this.makeFormControl({
            name: 'estimate',
            label: true,
            control: this.select("estimate", this.model.point_values(), {blank: 'No estimate'})
          }));
          $(div).append(this.makeFormControl({
            name: "story_type",
            label: true,
            control: this.select("story_type", ["feature", "chore", "bug", "release"])
          }));
          $(div).append(this.makeFormControl({
            name: "state",
            label: true,
            control: this.select("state", ["unscheduled", "unstarted", "started", "finished", "delivered", "accepted", "rejected"])
          }));
        })
      );

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).addClass('form-inline');
          $(div).append(this.makeFormControl({
            name: "requested_by_id",
            label: true,
            control: this.select("requested_by_id",
              this.model.collection.project.users.forSelect(),{blank: '---'})
          }));
          $(div).append(this.makeFormControl({
            name: "owned_by_id",
            label: true,
            control: this.select("owned_by_id",
              this.model.collection.project.users.forSelect(),{blank: '---'})
          }));
        })
      );

      this.$el.append(
        this.makeFormControl({
          name: "labels",
          label: true,
          control: this.textField("labels"),
          class: 'form-control'
        })
      );

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).append(this.label("description", "Description"));
          $(div).append('<br/>');
          if(this.model.isNew() || this.model.get('editingDescription')) {
            $(div).append(this.textArea("description"));
          } else {
            var description = this.make('div');
            $(description).addClass('description');
            $(description).html(
              window.md.makeHtml(this.model.escape('description'))
            );
            $(div).append(description);
            $(description).after(
              this.make('input', {
                class: 'edit-description',
                type: 'button',
                value: I18n.t('edit')
              })
            );
          }
        })
      );

      this.$el.append(
        this.makeFormControl(function(div) {
          var random = (Math.floor(Math.random() * 10000) + 1);
          var progress_element_id = "documents_progress_" + random;
          var attachinary_container_id = "attachinary_container_" + random;

          $(div).append(this.fileField("documents", progress_element_id, attachinary_container_id));
          $(div).append("<span id='" + progress_element_id + "'>0%</span>");
          $(div).append('<div id="' + attachinary_container_id + '"></div>');

          // FIXME: refactor to a separated AttachmentView or similar
          // must run the plugin after the element is available in the DOM, not before, hence, the setTimeout
          clearTimeout(window.executeAttachinaryTimeout);
          window.executeAttachinaryTimeout = setTimeout(executeAttachinary, 1000);
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
      'story', this.model.get('story_type'), this.model.get('state')
    ].join(' ');
    if (this.model.estimable() && !this.model.estimated()) {
      className += ' unestimated';
    }
    if (this.isSearchResult) {
      className += ' searchResult';
    }
    this.className = this.el.className = className;
    return this;
  },

  saveInProgress: false,

  disableForm: function() {
    this.$el.find('input,select,textarea').attr('disabled', 'disabled');
    this.$el.find('a.collapse,a.expand').removeClass(/icons-/).addClass('icons-throbber');
  },

  enableForm: function() {
    this.$el.find('a.collapse').removeClass(/icons-/).addClass("icons-collapse");
  },

  initTags: function() {
    var model = this.model;
    var $input = this.$el.find("input[name='labels']");
    $input.tagit({
      availableTags: model.collection.labels
    });

    // Manually bind labels for now
    $input.on('change', function(){
      model.set({ labels: $(this).val()});
    });
  },

  renderNotes: function() {
    if (this.model.notes.length > 0) {
      var el = this.$el;
      el.append('<hr/>');
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
    this.model.notes.add({});
    this.$el.find('a.collapse,a.expand').removeClass(/icons-/).addClass('icons-throbber');
  },

  enableForm: function() {
    this.$el.find('a.collapse').removeClass(/icons-/).addClass("icons-collapse");
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
      delay: 200,
      html: true,
      trigger: 'hover'
    });
  },

  removeHoverbox: function() {
    $('.popover').remove();
  },

  initTags: function() {
    var model = this.model;
    var $input = this.$el.find("input[name='labels']");
    $input.tagit({
      availableTags: model.collection.labels
    });

    // Manually bind labels for now
    $input.on('change', function(){
      model.set({ labels: $(this).val()});
    });
  },

  setFocus: function() {
    if (this.model.get('editing') === true ) {
      this.$('input.title').first().focus();
    }
  },

  makeFormControl: function(content) {
    var div = this.make('div', {
      class: 'form-group'
    });
    if (typeof content == 'function') {
      content.call(this, div);
    } else if (typeof content == 'object') {
      var $div = $(div);
      if (content.label) {
        $div.append(this.label(content.name));
        $div.append('<br/>');
      }
      $div.append(content.control);
    }
    return div;
  }
});
