var TaskView = require('views/task_view');

describe('TaskView', function() {

  beforeEach(function() {
    var Task = Backbone.Model.extend({name: 'task', url: '/foo'});
    this.task = new Task({});
    TaskView.prototype.template = sinon.stub();
    this.view = new TaskView({model: this.task});
  });

  it("has div as the tag name", function() {
    expect(this.view.el.nodeName).toEqual('DIV');
  });

  it("has the task class", function() {
    expect($(this.view.el)).toHaveClass('task');
  });

  describe("removeTask", function() {
    it("should call destroy on the model", function() {
      var deleteSpy = sinon.spy(this.view.model, 'destroy');
      this.view.removeTask();
      expect(deleteSpy).toHaveBeenCalled();
    });

    it("should remove element", function() {
      var removeSpy = sinon.spy(this.view.$el, 'remove');
      this.view.removeTask();
      expect(removeSpy).toHaveBeenCalled();
    });
  });

  describe("updateTask", function() {
    it("should call save on the model", function() {
      var updateSpy = sinon.spy(this.view.model, 'save');
      this.view.updateTask();
      expect(updateSpy).toHaveBeenCalled();
    });
  });
});
