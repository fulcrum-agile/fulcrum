describe('StoryView', function() {

  beforeEach(function() {
    var Story = Backbone.Model.extend({
      name: 'story', defaults: {story_type: 'feature'},
      estimable: function() { return true },
      estimated: function() { return false },
      point_values: function() [0,1,2]
    });
    this.story = new Story({id: 999, title: 'Story'});
    this.new_story = new Story({title: 'New Story'});
    this.view = new StoryView({
      model: this.story
    });
    this.new_story_view = new StoryView({
      model: this.new_story
    });
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

  describe("expand collapse controls", function() {

    it("should not show the collapse control if its a new story", function() {
      this.new_story.set({editing: true});

      expect($(this.new_story_view.el)).not.toContain('img.collapse');
    });

  });

});
