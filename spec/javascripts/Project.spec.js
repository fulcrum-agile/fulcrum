describe('Project model', function() {

  beforeEach(function() {
    this.project = new Project({
      id: 999, title: 'Test project', point_values: [0, 1, 2, 3]
    });
  });

  describe('when instantiated', function() {

    it('should exhibit attributes', function() {
      expect(this.project.get('point_values'))
        .toEqual([0, 1, 2, 3]);
    });

    it('should set up a story collection', function() {
      expect(this.project.stories).toBeDefined();
      expect(this.project.stories.url).toEqual('/projects/999/stories')
      // Sets up a reference on the collection to itself
      expect(this.project.stories.project).toBe(this.project);
    });

  });

  describe('url', function() {

    it('should have a url', function() {
      expect(this.project.url()).toEqual('/projects/999');
    });

  });
});
