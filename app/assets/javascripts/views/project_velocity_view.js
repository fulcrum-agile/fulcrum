var ProjectVelocityView = Backbone.View.extend({

  className: 'velocity',

  initialize: function() {
    _.bindAll(this, 'setFakeClass', 'render');
    this.override_view = new ProjectVelocityOverrideView({model: this.model});
    this.model.bind('change:userVelocity', this.setFakeClass);
    this.model.bind('rebuilt-iterations', this.render);
  },

  events: {
    "click #velocity_value": "editVelocityOverride"
  },

  template: _.template(
                'Velocity: <span id="velocity_value"><%= project.velocity() %></span>'
              ),

  render: function() {
    this.$el.html(this.template({project: this.model}));
    this.setFakeClass(this.model);
    return this;
  },

  editVelocityOverride: function() {
    this.$el.append(this.override_view.render().el);
  },

  setFakeClass: function(model) {
    if (model.velocityIsFake()) {
      this.$el.addClass('fake');
    } else {
      this.$el.removeClass('fake');
    }
  }
});
