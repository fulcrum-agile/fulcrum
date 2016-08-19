if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.EpicView = Backbone.View.extend({

  initialize: function(options) {
    this.options = options;
    $('td.epic_column').css('display', 'table-cell');
    this.doSearch();
  },

  addBar: function(column) {
    var that = this;
    var view = new Fulcrum.EpicBarView({model: this.model}).render();
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
    var that = this;

    $('#epic').html("");
    $('td.epic_column').show();
    this.addBar('#epic');

    var search_results_ids = this.model.search.pluck("id");
    var stories = this.model.stories;
    _.each(search_results_ids, function(id) {
      that.addStory(stories.get(id), '#epic');
    });

    $(".loading_screen").hide();
  },

  doSearch: function(e) {
    $(".loading_screen").show();
    var that = this;
    this.model.search.fetch({
      reset: true,
      data: {
        label: this.options.label
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
