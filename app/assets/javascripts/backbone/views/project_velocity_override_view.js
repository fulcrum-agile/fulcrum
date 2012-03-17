var ProjectVelocityOverrideView = Backbone.View.extend({

  className: 'velocity_override_container',

  events: {
    "click button[name=apply]": "changeVelocity",
    "click button[name=revert]": "revertVelocity",
    "keydown input[name=override]": "keyCapture"
  },

  template: _.template(
              '<form>' +
              '  <ul>' +
              '    <li>Override Velocity:' +
              '      <input name="override" size=2 value=<%= project.velocity() %> />' +
              '    </li>' +
              '    <li>' +
              '      <button name="revert" value="revert">Revert</button>' +
              '      <button name="apply" value="apply">Apply</button>' +
              '    </li>' +
              '  </ul>' +
              '</form>'
            ),

  render: function() {
    $(this.el).html(this.template({project: this.model}));
    this.delegateEvents();
    return this;
  },

  changeVelocity: function() {
    this.model.velocity(parseInt($("input[name=override]").val(), 10));
    $(this.el).remove();
    return false;
  },

  revertVelocity: function() {
    this.model.revertVelocity();
    $(this.el).remove();
    return false;
  },

  keyCapture: function(e) {
    if(e.keyCode == '13') {
      this.changeVelocity();
    }
  }
});
