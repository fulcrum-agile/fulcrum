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

  });
});
