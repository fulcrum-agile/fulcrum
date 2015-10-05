if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.ProjectSearchView = Backbone.View.extend({

  initialize: function() {
  },

  events: {
    "submit": "doSearch"
  },

  addStory: function(story, column) {
    if (_.isUndefined(story)) {
      return;
    }
    var view = new Fulcrum.StoryView({model: story}).render();
    this.appendViewToColumn(view, column);
    view.setFocus();
  },

  appendViewToColumn: function(view, columnName) {
    $(columnName).append(view.el);
  },

  addAll: function() {
    $(".loading_screen").show();
    var that = this;

    $('#search_results').html("");
    $('.search_results_column').show();

    this.model.stories.each(function(story) {
      that.addStory(story, '#search_results');
    });
    $(".loading_screen").hide();
  },

  doSearch: function(e) {
    e.preventDefault();
    var that = this;
    this.model.stories.fetch({
      data: {
        q: this.$el.find('input[type=text]').val()
      },
      success: function() {
        that.addAll();
      },
      error: function(e) {
        console.log('error ' + e);
      }
    });
  },

});

