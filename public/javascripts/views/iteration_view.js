var IterationView = Backbone.View.extend({

  className: 'iteration',

  render: function() {

    var points;

    if (this.model.get('column') === '#in_progress') {
      points = this.model.acceptedPoints() + '/' + this.model.points();
    } else {
      points = this.model.points();
    }

    var pointsSpan = this.make('span', {'class': 'points'}, points.toString());
    var el = $(this.el);
    el.html(this.model.get('number').toString() + ' - ' + this.model.startDate().toDateString());
    el.append(pointsSpan);
    return this;
  }

});
