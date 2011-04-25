$(function(){
  // The 'Add story button' should show the hidden form at the bottom of the
  // backlog
  $('#new_story').hide();
  //$('#add_story').click(function() {
  //  $('#new_story').toggle();
  //  $('#story_title').focus();
  //  return false;
  //});
});

/**
 * Loads an entire column from a remote data path.  path is the path of the
 * url to call, column_id is the element id to append the data to.
 */
function loadColumn(path, column_id) {
  $.ajax({
    dataType: "json",
    url: path,
    success: function(stories) {
      $('#story_tmpl').tmpl(stories).appendTo(column_id);
    }
  });
}

// Backbone implementation

var Story = Backbone.Model.extend({
  name: 'story',

  defaults: {
    events: [],
    state: "unstarted",
    story_type: "feature"
  },

  column: function() {
    if (this.get('state') == "accepted") {
      return '#done';
    }
    else if (this.get('state') == "unstarted") {
      return "#backlog";
    }
    else {
      return "#in_progress";
    }
  },

  clear: function() {
    this.destroy();
    this.view.remove();
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

  className: function() {
    return 'story ' + this.get('story_type');
  }
});

var StoryCollection = Backbone.Collection.extend({
  model: Story,
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
    _.bindAll(this, "render", "highlight");
    // Rerender on any change to the views story
    this.model.bind("change", this.render);
    this.model.bind("change", this.highlight);

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
    "click #destroy": "clear"
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
      $(div).append(this.select("state", ["unstarted", "started", "finished", "delivered", "accepted", "rejected"]));
      $(this.el).append(div);

      div = this.make('div');
      $(div).append(this.label("description"));
      $(div).append('<br/>');
      $(div).append(this.textArea("description"));
      $(this.el).append(div);

    } else {
      $(this.el).html($('#story_tmpl').tmpl(this.model.toJSON()));
      //var view = this;
      //$(this.el).find('img.expand').bind("click", function() {
      //  view.model.set({editing: true});
      //  view.render();
      //});
    }
    return this;
  }
});

//var Stories = new StoryCollection();
//var Project = new Project({id: 1});

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
    $(story.column()).append(view.render().el);
  },

  addAll: function() {
    window.Project.stories.each(this.addOne);
  }
});

$(function() {
  $('#add_story').click(function() {
    window.Project.stories.add([{
      title: "New story", events: [], editing: true
    }]);
  });
});
