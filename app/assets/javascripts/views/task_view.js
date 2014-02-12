if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.TaskView = Fulcrum.FormView.extend({

  template: JST['templates/task'],

  tagName: 'div',

  className: 'task',

  events: {
    "change input": "updateTask",
    "click a.delete-task": "removeTask",
  },

  render: function() {
    var view = this;

    div = this.make('div');
    $(div).append(this.checkBox("done"));
    $(div).append( this.template({task: this.model}) );
    this.$el.html(div);
    
    return this;
  },

  updateTask: function() {
    /*
     * Ignore this.checkBox() element bindng (bindElementToAttribute)
     * since check/uncheck does not update value
     */
    var done = this.$el.find("input").is(":checked");
    this.model.set('done', done);
    this.model.save(null);
  },

  removeTask: function() {
    this.model.destroy();
    this.$el.remove();
    return false;
  }

});

