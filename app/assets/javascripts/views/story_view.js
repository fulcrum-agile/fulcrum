var Clipboard = require('clipboard');

var executeAttachinary = require('libs/execute_attachinary');

var FormView = require('./form_view');
var EpicView = require('./epic_view');
var NoteForm = require('./note_form');
var NoteView = require('./note_view');
var TaskForm = require('./task_form');
var TaskView = require('./task_view');

module.exports = FormView.extend({

  template: require('templates/story.ejs'),

  tagName: 'div',

  initialize: function(options) {
    _.extend(this, _.pick(options, "isSearchResult"));

    _.bindAll(this, "render", "highlight", "moveColumn", "setClassName",
      "transition", "estimate", "disableForm", "renderNotes",
      "renderNotesCollection", "addEmptyNote", "hoverBox",
      "renderTasks", "renderTasksCollection", "addEmptyTask");

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

    this.model.on("change:tasks", this.addEmptyTask);
    this.model.on("change:tasks", this.renderTasksCollection);

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
    // Add an empty task to the collection
    this.addEmptyTask();
  },

  isReadonly: function() {
    return this.model.isReadonly;
  },

  events: {
    "click": "startEdit",
    "click .epic-link": "openEpic",
    "click .submit": "saveEdit",
    "click .cancel": "cancelEdit",
    "click .transition": "transition",
    "click .state-actions .estimate": "estimate",
    "change select.story_type": "disableEstimate",
    "click .destroy": "clear",
    "click .description": "editDescription",
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
    _.each(I18n.t('story.events'), function(value, key) {
      if( value == transitionEvent )
        transitionEvent = key;
    })

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
    this.model.set({estimate: ev.target.attributes['data-value'].value});

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

  disableEstimate: function () {
    var $storyEstimate = this.$el.find('.story_estimate');

    if (this.model.notEstimable()) {
      this.model.set({estimate: null});
      $storyEstimate.attr('disabled', 'disabled');
    } else {
      $storyEstimate.removeAttr('disabled');
    }
  },

  canEdit: function() {
    var isEditable              = this.model.get('editing');
    var isSearchResultContainer = this.$el.hasClass('searchResult');
    var clickFromSearchResult   = this.model.get('clickFromSearchResult');
    if (_.isUndefined(isEditable))
      isEditable = false;
    if (_.isUndefined(clickFromSearchResult))
      clickFromSearchResult = false;
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
    if (this.eventShouldExpandStory(e)) {
      this.model.set({editing: true, editingDescription: false, clickFromSearchResult: this.$el.hasClass('searchResult')});
      this.removeHoverbox();
    }
  },

  openEpic: function(e){
    e.stopPropagation();
    var label = $(e.target).text();
    new EpicView({model: this.model.collection.project, label: label});
  },

  // When a story is clicked, this method is used to check whether the
  // corresponding click event should expand the story into its form view.
  eventShouldExpandStory: function(e) {
    // Shouldn't expand if it's already expanded.
    if (this.canEdit()) {
      return false;
    }
    // Should expand if the click wasn't on one of the buttons.
    if ($(e.target).is('input')) return false
    if ($(e.target).is('.input')) return false
    return true;
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

  saveEdit: function(event) {
    this.disableForm();

    // Call this here to ensure the story gets it's accepted_at date set
    // before the story collection callbacks are run if required.  The
    // collection callbacks need this to be set to know which iteration to
    // put an accepted story in.
    this.model.setAcceptedAt();

    var that = this;
    documents = $(event.currentTarget).closest('.story').find("[type='hidden'][name='documents[]']");

    this.model.save(null, { documents: documents,
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
          if(!this.isReadonly()) {
            $(div).append(this.submit());
            if (!this.model.isNew()) {
              $(div).append(this.destroy());
            }
          }
          $(div).append(this.cancel());
        })
      );

      if (this.id != undefined) {
        this.$el.append(
          this.makeFormControl(function(div) {
            $(div).append('<input id="story-link-' + this.id + '" value="' + window.location + '#story-' + this.id + '" class="story_link" readonly/>');
            $(div).append('<button class="btn-clipboard" data-clipboard-target="#story-link-' + this.id + '"><img src="/clippy.svg" alt="Copy to clipboard" width="10px"></button>');
          })
        );
        // activate the clipboard link
        new Clipboard('.btn-clipboard');
      }

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).append(this.textField("title", {
            'class' : 'title form-control input-sm',
            'placeholder': I18n.t('story title'),
            'maxlength': 255,
            'disabled': this.isReadonly()
          }));
        })
      );

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).addClass('form-inline');
          $(div).append(this.makeFormControl({
            name: 'estimate',
            label: true,
            control: this.select("estimate", this.model.point_values(), {
              blank: I18n.t('story.no_estimate'),
              attrs: {
                class: ['story_estimate'],
                disabled: this.model.notEstimable() || this.isReadonly()
              }
            })
          }));
          var story_type_options = [];
          _.each(["feature", "chore", "bug", "release"], function(option) {
            story_type_options.push([I18n.t('story.type.' + option), option])
          });
          $(div).append(this.makeFormControl({
            name: "story_type",
            label: true,
            disabled: true,
            control: this.select("story_type", story_type_options, {
              attrs: {
                class: ['story_type'],
                disabled: this.isReadonly()
              }
            })
          }));
          var story_state_options = [];
          _.each(["unscheduled", "unstarted", "started", "finished", "delivered", "accepted", "rejected"], function(option) {
            story_state_options.push([ I18n.t('story.state.' + option), option ])
          });
          $(div).append(this.makeFormControl({
            name: "state",
            label: true,
            control: this.select("state", story_state_options, {
              attrs: {
                class: [],
                disabled: this.isReadonly()
              }
            })
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
              this.model.collection.project.users.forSelect(), {
                blank: '---',
                attrs: {
                  class: [],
                  disabled: this.isReadonly()
                }
            })
          }));
          $(div).append(this.makeFormControl({
            name: "owned_by_id",
            label: true,
            control: this.select("owned_by_id",
              this.model.collection.project.users.forSelect(), {
                blank: '---',
                attrs: {
                  class: [],
                  disabled: this.isReadonly()
                }
            })
          }));
        })
      );

      this.$el.append(
        this.makeFormControl({
          name: "labels",
          label: true,
          control: this.textField("labels"),
          class: 'form-control',
          disabled: this.isReadonly()
        })
      );

      this.$el.append(
        this.makeFormControl(function(div) {
          $(div).append(this.label("description", I18n.t('activerecord.attributes.story.description')));
          $(div).append('<br/>');
          if(this.model.isNew() || this.model.get('editingDescription')) {
            var textarea = this.textArea("description");
            $(textarea).atwho({
              at: "@",
              data: window.projectView.usernames(),
            });
            $(div).append(textarea);
          } else {
            var description = this.make('div');
            $(description).addClass('description');
            $(description).html(
              window.md.makeHtml(this.model.escape('description'))
            );
            $(div).append(description);
            if (!this.model.get('description') || 0 === this.model.get('description').length) {
              $(description).after(
                this.make('input', {
                  class: this.isReadonly() ? '' : 'edit-description',
                  type: 'button',
                  value: I18n.t('edit')
                })
              );
            }
          }
        })
      );

      this.renderTasks();

      this.$el.append(
        this.makeFormControl(function(div) {
          var random = (Math.floor(Math.random() * 10000) + 1);
          var progress_element_id = "documents_progress_" + random;
          var finished_element_id = "documents_finished_" + random;
          var attachinary_container_id = "attachinary_container_" + random;

          $(div).append(this.label('attachments', I18n.t('story.attachments')));
          $(div).addClass('uploads');
          if(!this.isReadonly()) {
            $(div).append(this.fileField("documents", progress_element_id, finished_element_id, attachinary_container_id));
            $(div).append("<div id='" + progress_element_id + "' class='attachinary_progress_bar'></div>");
            $(div).append('<div id="' + finished_element_id + '" class="attachinary_finished_message">Click the "save" button above!</div>');
          }
          $(div).append('<div id="' + attachinary_container_id + '"></div>');

          // FIXME: refactor to a separated AttachmentView or similar
          // must run the plugin after the element is available in the DOM, not before, hence, the setTimeout
          clearTimeout(window.executeAttachinaryTimeout);
          window.executeAttachinaryTimeout = setTimeout(executeAttachinary, 500);
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
      var that = this;
      setTimeout(function() {
        model.set({ labels: $(that).val()});
      }, 50);
    });
  },

  renderNotes: function() {
    if (this.model.notes.length > 0) {
      var el = this.$el;
      el.append(this.label('notes', I18n.t('story.notes')));
      el.append('<div class="notelist"/>');
      this.renderNotesCollection();
    }
  },

  renderTasks: function() {
    if (this.model.tasks.length > 0) {
      var el = this.$el;
      el.append(this.label('tasks', I18n.t('story.tasks')));
      el.append('<div class="tasklist"/>');
      this.renderTasksCollection();
    }
  },

  renderNotesCollection: function() {
    var notelist = this.$('div.notelist');
    notelist.html('');
    if(!this.isReadonly())
      this.addEmptyNote();
    var that = this;
    this.model.notes.each(function(note) {
      var view;
      if (!that.isReadonly() && note.isNew()) {
        view = new NoteForm({model: note});
      } else {
        if (that.isReadonly()) note.isReadonly = true;
        view = new NoteView({model: note});
      }
      notelist.append(view.render().el);
    });
  },

  renderTasksCollection: function() {
    var tasklist = this.$('div.tasklist');
    tasklist.html('');
    if(!this.isReadonly())
      this.addEmptyTask();
    var that = this;
    this.model.tasks.each(function(task) {
      var view;
      if (!that.isReadonly() && task.isNew()) {
        view = new TaskForm({model:task});
      } else {
        if (that.isReadonly()) task.isReadonly = true;
        view = new TaskView({model:task});
      }
      tasklist.append(view.render().el);
    });
  },

  addEmptyTask: function() {
    if (this.model.isNew()) {
      return;
    }

    var task = this.model.tasks.last();
    if (task && task.isNew()) {
      return;
    }

    this.model.tasks.add({});
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

  // FIXME Move to separate view
  hoverBox: function(){
    var view  = this;
    this.$el.find('.popover-activate').popover({
      title: function(){
        return view.model.get("title");
      },
      content: function(){
        return require('templates/story_hover.ejs')({
          story: view.model,
          noteTemplate: require('templates/note.ejs')
        });
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
