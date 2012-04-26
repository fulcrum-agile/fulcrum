if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.IterationView = Backbone.View.extend({

  template: JST['templates/iteration'],

  className: 'iteration',

  render: function() {
    this.$el.html(this.template({iteration: this.model, view: this}));
    return this;
  },

  // Returns the number of points in the iteration, unless the iteration is
  // the current iteration, in which case returns 'accepted/total' points.
  points: function() {
    if (this.model.get('column') === '#in_progress') {
      return this.model.acceptedPoints() + '/' + this.model.points();
    } else {
      return this.model.points();
    }
  }

});
