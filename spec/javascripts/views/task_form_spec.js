var TaskForm = require('views/task_form');

describe("TaskForm", function() {

  beforeEach(function() {
    var Task = Backbone.Model.extend({name: 'task', url: '/foo'});
    this.task = new Task({});
    TaskForm.prototype.template = sinon.stub();
    this.view = new TaskForm({model: this.task});
  });

  it("should have a tag name of div", function() {
    expect(this.view.el.nodeName).toEqual('DIV');
  });

  it("should have a class of task_form", function() {
    expect($(this.view.el)).toHaveClass('task_form');
  });

  describe("saveTask", function() {

    it("should disable all form controls on submit", function() {
      var disableSpy = sinon.spy(this.view, 'disableForm');
      sinon.stub(this.task, 'save');
      this.view.saveTask();
      expect(disableSpy).toHaveBeenCalled();
    });

  });

  describe("disableForm", function() {

    it("sets disabled state on form tags", function() {
      $(this.view.el).html('<input type="text"></input><input type="submit">');
      this.view.disableForm();
      expect(this.view.$('input').attr('disabled')).toBeTruthy();
    });

    it("sets saving class on the submit button", function() {
      $(this.view.el).html('<input type="button">');
      this.view.disableForm();
      expect(this.view.$('input[type="button"]')).toHaveClass('saving');
    });

  });

  describe("enableForm", function() {

    it("removes disabled state from form tags", function() {
      $(this.view.el).html('<input type="text" disabled="disabled"></input><input type="submit" disabled="disabled">');
      this.view.enableForm();
      expect(this.view.$('input').attr('disabled')).toBeFalsy();
    });

    it("removes saving class from the submit button", function() {
      $(this.view.el).html('<input type="button" class="saving">');
      this.view.enableForm();
      expect(this.view.$('input[type="button"]')).not.toHaveClass('saving');
    });

  });
});
