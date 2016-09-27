module.exports = Backbone.View.extend({

  template: require('templates/epic_bar.ejs'),

  className: 'iteration',

  render: function() {
    this.$el.html(this.template({points: this.points(), done: this.donePoints(), remaining: this.remainingPoints()}));
    return this;
  },

  points: function() {
    var estimates = this.model.search.pluck('estimate')

    return this.sumPoints(estimates);
  },

  donePoints: function() {
    var estimates = _.map(this.done(), function(e) { return e.get('estimate') })

    return this.sumPoints(estimates);
  },

  remainingPoints: function(){
    var estimates = _.map(this.remaining(), function(e) { return e.get('estimate') })

    return this.sumPoints(estimates);;
  },

  done: function() {
    return _.select(this.model.search.models, function(story) {
      return (story.get('state') === 'accepted');
    });
  },

  remaining: function(){
    return _.select(this.model.search.models, function(story) {
      return (story.get('state') != 'accepted');
    });
  },

  sumPoints: function(estimates) {
    var sum = _.reduce(estimates, function(total, estimate) {
      return total + estimate;
    })

    return sum;
  }
});
