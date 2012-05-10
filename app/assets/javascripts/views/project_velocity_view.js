if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.ProjectVelocityView = Backbone.View.extend({

  className: 'velocity',

  initialize: function() {
    _.bindAll(this, 'setFakeClass', 'render');
    this.override_view = new Fulcrum.ProjectVelocityOverrideView({model: this.model});
    this.model.bind('change:userVelocity', this.setFakeClass);
    this.model.bind('rebuilt-iterations', this.render);
  },

  events: {
    "click #velocity_value": "editVelocityOverride"
  },

  template: JST['templates/project_velocity'],

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
