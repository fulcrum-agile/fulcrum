var ProjectVelocityView = Backbone.View.extend({

  // TODO - Bind to changes

  className: 'velocity',

  render: function() {
    $(this.el).html('Velocity: ' + this.model.velocity());
    return this;
  }
});
