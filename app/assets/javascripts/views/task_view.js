var FormView = require('./form_view');

module.exports = FormView.extend({

  template: require('templates/task.ejs'),

  tagName: 'div',

  className: 'task',

  events: {
    "click a.delete-task": "removeTask",
    "change input": "updateTask"
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
  },

  updateTask: function() {
    var done = this.$el.find("input").is(":checked");
    this.model.set('done', done);
    this.model.save(null);
  }

});
