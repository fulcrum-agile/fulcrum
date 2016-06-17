if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.EpicView = Backbone.View.extend({
  initialize: function(options) {
    this.options = options;
    $('td.epic_column').css('display', 'table-cell');
    this.doSearch();
  },

  render: function() {
    this.$el.html(this.options.columnView.name());
    this.setClassName();
    return this;
  },

  addStory: function(story, column) {
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

    $('#epic').html("");
    $('td.epic_column').show();

    var search_results_ids = this.model.search.pluck("id");
    var stories = this.model.stories;
    _.each(search_results_ids, function(id) {
      that.addStory(stories.get(id), '#epic');
    });

    $(".loading_screen").hide();
  },

  doSearch: function(e) {
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
