module.exports = Backbone.View.extend({

  className: 'velocity_override_container',

  events: {
    "click button[name=apply]": "changeVelocity",
    "click button[name=revert]": "revertVelocity",
    "keydown input[name=override]": "keyCapture"
  },

  template: require('templates/project_velocity_override.ejs'),

  render: function() {
    this.$el.html(this.template({project: this.model}));
    this.delegateEvents();
    this.clickOverlayOn();
    return this;
  },

  changeVelocity: function() {
    this.model.velocity(this.requestedVelocityValue());
    this.clickOverlayOff();
    return false;
  },

  revertVelocity: function() {
    this.model.revertVelocity();
    this.clickOverlayOff();
    return false;
  },

  requestedVelocityValue: function() {
    return parseInt(this.$("input[name=override]").val(), 10);
  },

  keyCapture: function(e) {
    if(e.keyCode == '13') {
      this.changeVelocity();
    }
  },

  clickOverlayOn: function() {
    var that = this;
    this.$el.css('z-index', 2000);
    $('.click-overlay').on('click', function() {
      that.clickOverlayOff();
    });
    $('.click-overlay').show();
  },

  clickOverlayOff: function() {
    $('.click-overlay').off('click');
    this.$el.remove();
    $('.click-overlay').hide();
  }
});
