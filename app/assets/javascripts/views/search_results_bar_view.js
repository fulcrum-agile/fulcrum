module.exports = Backbone.View.extend({

  template: JST['templates/search_results_bar'],

  className: 'iteration',

  render: function() {
    this.$el.html(this.template({stories: this.model.search.length, points: this.points()}));
    return this;
  },

  points: function() {
    var estimates = this.model.search.pluck('estimate')
    var sum = _.reduce(estimates, function(total, estimate) {
      return total + estimate;
    })
    return sum;
  }

});

