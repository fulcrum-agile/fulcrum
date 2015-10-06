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
    var view = new Fulcrum.StoryView({model: story, isSearchResult: true}).render();
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

    var search_results_ids = this.model.search.pluck("id");
    var stories = this.model.stories;
    _.each(search_results_ids, function(id) {
      that.addStory(stories.get(id), '#search_results');
    });

    $(".loading_screen").hide();
  },

  doSearch: function(e) {
    e.preventDefault();
    var that = this;
    this.model.search.fetch({
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

