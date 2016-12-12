module.exports = Backbone.View.extend({

  template: require('templates/iteration.ejs'),

  className: 'iteration',

  events: {
    "click": "toggleStories",
  },

  toggleStories: function() {
    var item = this.$el.next();
    while(true) {
      if ($(item).hasClass('story')) {
        $(item).toggle();
      }
      item = item.next();
      if (item.length == 0 || $(item).hasClass('iteration')) {
        break;
      }
    }
  },

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
