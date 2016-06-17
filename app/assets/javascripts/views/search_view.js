if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.SearchView = Backbone.View.extend({

  TAGS_REGEX: /tags:([a-z,]*)/i,

  template: JST['templates/search'],

  events: {
    'change input': 'search'
  },

  initialize: function() {
    var that = this;

    Fulcrum.appRouter.on('route:search', function(params) {
      params = _.queryParams(params);
      var search = '';

      if (params.tags) {
        search = 'tags:' + params.tags + ' ';
      }

      if (params.text) {
        search += params.text;
      }

      that.input.val(search);
    });
  },

  render: function() {
    this.$el.html(this.template);
    this.input = this.$el.find('input');

    return this;
  },

  search: function() {
    var params = this.input.val();
    var tags = this.TAGS_REGEX.exec(params);
    var options = {};

    if (tags) {
      options.tags = tags[1];
      params = params.replace(tags[0], '');
    }

    if (params) {
      options.text = params.trim();
    }

    if (params || tags) {
      Fulcrum.appRouter.navigate('search?' + $.param(options), {trigger: true});
    } else {
      Fulcrum.appRouter.navigate('/', {trigger: true});
    }
  }

});
