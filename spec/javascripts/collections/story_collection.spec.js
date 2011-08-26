describe('StoryCollection collection', function() {

  beforeEach(function() {
    this.story1 = new Story({id: 1, title: "Story 1", position: '10.0'});
    this.story2 = new Story({id: 2, title: "Story 2", position: '20.0'});
    this.story3 = new Story({id: 3, title: "Story 3", position: '30.0'});

    this.stories = new StoryCollection();
    this.stories.add([this.story3, this.story2, this.story1]);
  });

  describe('position', function() {

    it('should return stories in position order', function() {
      expect(this.stories.at(0)).toBe(this.story1);
      expect(this.stories.at(1)).toBe(this.story2);
      expect(this.stories.at(2)).toBe(this.story3);
    });

    it('should move between 2 other stories', function() {

      expect(this.stories.at(2)).toBe(this.story3);

      this.story3.moveBetween(1,2);
      expect(this.story3.position()).toEqual(15.0);
      expect(this.stories.at(1).id).toEqual(this.story3.id);
    });

    it('should move after another story', function() {

      expect(this.stories.at(2)).toBe(this.story3);

      this.story3.moveAfter(1);
      expect(this.story3.position()).toEqual(15.0);
      expect(this.stories.at(1).id).toEqual(this.story3.id);
    });

    it('should move after the last story', function() {
      expect(this.stories.at(2)).toBe(this.story3);
      this.story1.moveAfter(3);
      expect(this.story1.position()).toEqual(31.0);
      expect(this.stories.at(2).id).toEqual(this.story1.id);
    });

    it('should move before the first story', function() {
      expect(this.stories.at(0)).toBe(this.story1);
      this.story3.moveBefore(1);
      expect(this.story3.position()).toEqual(5.0);
      expect(this.stories.at(0).id).toEqual(this.story3.id);
    });

    it('should move before another story', function() {

      expect(this.stories.at(2)).toBe(this.story3);

      this.story3.moveBefore(2);
      expect(this.story3.position()).toEqual(15.0);
      expect(this.stories.at(1).id).toEqual(this.story3.id);
    });

    it('should return the story after a given story', function() {
      expect(this.stories.next(this.story1)).toBe(this.story2);

      // Should return undefined if there is no next story
      expect(this.stories.next(this.story3)).toBeUndefined();
    });

    it('should return the story before a given story', function() {
      expect(this.stories.previous(this.story3)).toBe(this.story2);

      // Should return undefined if there is no previous story
      expect(this.stories.previous(this.story1)).toBeUndefined();
    });

    it("should reset whenever a models position attr changes", function() {
      var spy = sinon.spy();
      this.stories.bind("reset", spy);
      this.story1.set({position: 0.5});
      expect(spy).toHaveBeenCalled();
    });

    it("should reset whenever a models state changes", function() {
      var spy = sinon.spy();
      this.stories.bind("reset", spy);
      this.story1.set({state: 'unstarted'});
      expect(spy).toHaveBeenCalled();
    });

  });

  describe("columns", function() {

    it("should return all stories in the done column", function() {
      expect(this.stories.column('#done')).toEqual([]);
      this.story1.column = function() {return '#done';};
      expect(this.stories.column('#done')).toEqual([this.story1]);
    });

    it("returns a set of columns", function() {
      this.story1.column = function() {return '#done';};
      this.story2.column = function() {return '#current';};
      this.story3.column = function() {return '#backlog';};
      expect(this.stories.columns(['#backlog', '#current', '#done']))
        .toEqual([this.story3,this.story2,this.story1]);
    });

  });
});
