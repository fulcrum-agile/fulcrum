if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.TaskView = Fulcrum.FormView.extend({

  template: JST['templates/task'],

  tagName: 'div',

  className: 'task',

  events: {
    "click a.delete-task": "removeTask"
  },

  render: function() {
    var view = this;

    div = this.make('div');
    $(div).append(this.checkBox("done"));
    $(div).append( this.template({task: this.model}) );
    this.$el.html(div);
    
    return this;
  },

  removeTask: function() {
    this.model.destroy();
    this.$el.remove();
    return false;
  }

});
