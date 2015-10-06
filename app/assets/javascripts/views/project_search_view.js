if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.ProjectSearchView = Backbone.View.extend({

  initialize: function() {
  },

  events: {
    "submit": "doSearch"
  },

  addBar: function(column) {
    var that = this;
    var view = new Fulcrum.SearchResultsBarView({model: this.model}).render();
    this.appendViewToColumn(view, column);
  },

  addStory: function(story, column) {
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

    this.addBar('#search_results');

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
        window.projectView.notice({
          title: 'Search Error',
          text: e
        });
      }
    });
  },

});

