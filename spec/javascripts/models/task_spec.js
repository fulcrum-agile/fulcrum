var Task = require('models/task');

describe("Task", function() {

  beforeEach(function() {
    this.task = new Task({});
  });

  describe("story", function() {

    beforeEach(function() {
      this.task.set({story_id: 999, name: 'Foobar'});
    });

    it("returns the name task", function() {
      expect(this.task.get('name')).toEqual('Foobar');
    });

    it("returns the story_id", function() {
      expect(this.task.get('story_id')).toEqual(999);
    });

  });

  describe("errors", function() {

    it("should record errors", function() {
      expect(this.task.hasErrors()).toBeFalsy();
      expect(this.task.errorsOn('name')).toBeFalsy();

      this.task.set({errors: {
        name: ["cannot be blank", "needs to be better"]
      }});

      expect(this.task.hasErrors()).toBeTruthy();
      expect(this.task.errorsOn('name')).toBeTruthy();

      expect(this.task.errorMessages())
        .toEqual("name cannot be blank, name needs to be better");
    });

  });

  describe('humanAttributeName', function() {

    beforeEach(function() {
      I18n = {t: sinon.stub()};
      I18n.t.withArgs('foo_bar').returns('Foo bar');
    });

    it("returns the translated attribute name", function() {
      expect(this.task.humanAttributeName('foo_bar')).toEqual('Foo bar');
    });

    it("strips of the id suffix", function() {
      expect(this.task.humanAttributeName('foo_bar_id')).toEqual('Foo bar');
    });
  });
});
