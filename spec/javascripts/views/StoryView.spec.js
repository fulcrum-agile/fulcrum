describe('StoryView', function() {

  beforeEach(function() {
    var Story = Backbone.Model.extend({
      name: 'story', defaults: {story_type: 'feature'},
      estimable: function() { return true },
      estimated: function() { return false },
      point_values: function() [0,1,2],
      errorsOn: function() { return false},
      url: '/path/to/story'
    });
    this.story = new Story({id: 999, title: 'Story'});
    this.new_story = new Story({title: 'New Story'});
    this.view = new StoryView({
      model: this.story
    });
    this.new_story_view = new StoryView({
      model: this.new_story
    });

    this.server = sinon.fakeServer.create();
  });

  afterEach(function() {
    this.server.restore();
  });

  describe('class name', function() {

    it('should have the story class', function() {
      expect($(this.view.el)).toHaveClass('story');
    });

    it('should have the story type class', function() {
      expect($(this.view.el)).toHaveClass('feature');
    });

    it('should have the unestimated class', function() {
      expect($(this.view.el)).toHaveClass('unestimated');

      // Should not have the unestimated class if it's been estimated
      sinon.stub(this.view.model, "estimated").returns(true);
      this.view.model.set({estimate: 1});
      expect($(this.view.el)).not.toHaveClass('unestimated');
    });

  });

  describe("id", function() {

    it("should have an id", function() {
      expect(this.view.id).toEqual(this.view.model.id);
      expect($(this.view.el)).toHaveId(this.view.model.id);
    });

  });

  describe("cancel edit", function() {

    it("should remove itself when edit cancelled if its new", function() {
      var view = new StoryView({model: this.new_story});
      var spy = sinon.spy(this.new_story, "clear");

      view.cancelEdit();
      expect(spy).toHaveBeenCalled();
    });

  });

  describe("save edit", function() {

    it("should call save", function() {
      this.view.saveEdit();
      expect(this.server.requests.length).toEqual(1);
    });

    it("should set editing when errors occur", function() {
      this.server.respondWith(
        "PUT", "/path/to/story", [
          422, {"Content-Type": "application/json"},
          '{"story":{"errors":{"title":["cannot be blank"]}}}'
        ]
      );

      this.view.saveEdit();
      expect(this.server.responses.length).toEqual(1);
      expect(this.server.responses[0].method).toEqual("PUT");
      expect(this.server.responses[0].url).toEqual("/path/to/story");

      this.server.respond();

      expect(this.story.get('editing')).toBeTruthy();
      expect(this.story.get('errors').title[0]).toEqual("cannot be blank");
    });
  });

  describe("expand collapse controls", function() {

    it("should not show the collapse control if its a new story", function() {
      this.new_story.set({editing: true});

      expect($(this.new_story_view.el)).not.toContain('img.collapse');
    });

  });

});
