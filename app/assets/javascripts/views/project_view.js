var StoryView = require('./story_view');
var IterationView = require('./iteration_view');

module.exports = Backbone.View.extend({
  columns: {},

  initialize: function() {

    _.bindAll(this, 'addStory', 'addAll', 'render');

    this.model.stories.on('add', this.addStory);
    this.model.stories.on('reset', this.addAll);
    this.model.stories.on('all', this.render);
    this.model.on('change:userVelocity', this.addAll);

    var that = this;
    this.model.stories.fetch({
      success: function() {
        that.addAll();
      }
    });
  },

  // Triggered when the 'Add Story' button is clicked
  newStory: function() {
    if ($(window).width() <= 992) {
      _.each(this.columns, function(column, columnId) {
        if(columnId != 'chilly_bin')
          if(!column.hidden())
            column.toggle();
      });
    }
    this.model.stories.add([{
      events: [], files: [], editing: true
    }]);
  },

  addStory: function(story, column) {
    // If column is blank determine it from the story.  When the add event
    // is bound on a collection, the callback sends the collection as the
    // second argument, so also check that column is a string and not an
    // object for those cases.
    if (_.isUndefined(column) || !_.isString(column)) {
      column = story.column;
    }
    var view = new StoryView({model: story}).render();
    this.appendViewToColumn(view, column);
    view.setFocus();
  },

  appendViewToColumn: function(view, columnName) {
    $(columnName).append(view.el);
  },

  addIteration: function(iteration) {
    var that = this;
    var column = iteration.get('column');
    var view = new IterationView({model: iteration}).render();
    this.appendViewToColumn(view, column);
    _.each(iteration.stories(), function(story) {
      that.addStory(story, column);
    });
  },

  addAll: function() {
    $(".loading_screen").show();
    var that = this;

    _.each(this.columns, function(column, columnId) {
      column.$el.find('.storycolumn').html("");
    });

    this.model.rebuildIterations();

    // Render each iteration
    _.each(this.model.iterations, function(iteration) {
      var column = iteration.get('column');
      that.addIteration(iteration);
    });

    // Render the chilly bin.  This needs to be rendered separately because
    // the stories don't belong to an iteration.
    _.each(this.model.stories.column('#chilly_bin'), function(story) {
      that.addStory(story);
    });
    $(".loading_screen").hide();
    this.scrollToStory(window.location.hash || '');
  },

  scrollToStory: function(story_hash) {
    if ( story_hash.lastIndexOf('#story', 0) === 0 ) {
      var story = $(story_hash);
      if ( story.length > 0 ) {
        story.click();
        document.getElementById(story_hash.replace('#', '')).scrollIntoView();
        // clean url state so every refresh doesn't reopen the same story over and over
        if(window.history.pushState) {
            window.history.pushState('', '/', window.location.pathname)
        } else {
            window.location.hash = '';
        }
      }
    }
  },

  scaleToViewport: function() {
    var storyTableTop = $('table.stories tbody').offset().top;

    var extra = 20;

    var height = $(window).height() - (storyTableTop + extra);

    $('.storycolumn').css('height', height + 'px');

    if ($(window).width() <= 992) {
      _.each(this.columns, function(column, columnId) {
        if(columnId != 'in_progress')
          if(!column.hidden())
            column.toggle();
      });
      $('#form_search').hide();
    } else {
      $('#form_search').show();
    }
  },

  notice: function(message) {
    $.gritter.add(message);
  },

  addColumnView: function(id, view) {
    this.columns[id] = view;
  },

  addColumnViews: function(columns) {
    var that = this;
    _.each(columns, function(column, columnId) {
      column.on('visibilityChanged', that.checkColumnViewsVisibility);
      that.addColumnView(columnId, column);
    });
  },

  // make sure there is at least one column opened
  checkColumnViewsVisibility: function() {
    if (window.projectView === undefined)
      return;

    var filtered = _.filter(window.projectView.columns, function(column, columnId) {
      if(!column.hidden())
        return true;
    });

    if(filtered.length == 0) {
      window.projectView.columns['in_progress'].toggle();
    }
  },

  usernames: function() {
    return this.model.users
      .map(function(user) { return user.get('username'); })
      .sort();
  },

});
