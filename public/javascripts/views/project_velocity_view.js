var ProjectVelocityView = Backbone.View.extend({

  // TODO - Bind to changes

  className: 'velocity',

  initialize: function() {
    this.override_view = new ProjectVelocityOverrideView({model: this.model});
  },

  events: {
    "click #velocity_value": "editVelocityOverride"
  },

  template: _.template(
                'Velocity: <span id="velocity_value"><%= project.velocity() %></span>'
              ),

  render: function() {
    $(this.el).html(this.template({project: this.model}));
    return this;
  },

  editVelocityOverride: function() {
    $(this.el).append(this.override_view.render().el);
  }
});
