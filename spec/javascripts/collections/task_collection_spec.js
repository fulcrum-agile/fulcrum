var TaskCollection = require('collections/task_collection');

describe('TaskCollection', function() {

  beforeEach(function() {
    var Story = Backbone.Model.extend({name: 'story'});
    this.story = new Story({url: '/foo'});
    this.story.url = function() { return '/foo'; };

    this.task_collection = new TaskCollection();
    this.task_collection.story = this.story;
  });

  describe("url", function() {

    it("should return the url", function() {
      expect(this.task_collection.url()).toEqual('/foo/tasks');
    });

  });

  it("should return only saved tasks", function() {
    this.task_collection.add({id: 1, name: "Saved task"});
    this.task_collection.add({name: "Unsaved task"});
    expect(this.task_collection.length).toEqual(2);
    expect(this.task_collection.saved().length).toEqual(1);
  });

});
