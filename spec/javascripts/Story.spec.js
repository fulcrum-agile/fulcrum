describe('Story model', function() {

  beforeEach(function() {
    this.story = new Story({
      title: 'Test story'
    });
  });

  describe('when instantiated', function() {

    it('should exhibit attributes', function() {
      expect(this.story.get('title'))
        .toEqual('Test story');
    });

    it('should have a default state of unscheduled', function() {
      expect(this.story.get('state'))
        .toEqual('unscheduled');
    });

    it('should have a default column of chilly bin', function() {
      expect(this.story.get('column'))
        .toEqual('#chilly_bin');
    });

    it('should have a default story type of feature', function() {
      expect(this.story.get('story_type'))
        .toEqual('feature');
    });

    it('should have an empty array of events by default', function() {
      expect(this.story.get('events'))
        .toEqual([]);
    });

  });

  describe('state transitions', function() {

    it('should start', function() {
      this.story.start();
      expect(this.story.get('state')).toEqual('started');
    });

    it('should finish', function() {
      this.story.finish();
      expect(this.story.get('state')).toEqual('finished');
    });

    it('should deliver', function() {
      this.story.deliver();
      expect(this.story.get('state')).toEqual('delivered');
    });

    it('should accept', function() {
      this.story.accept();
      expect(this.story.get('state')).toEqual('accepted');
    });

    it('should reject', function() {
      this.story.reject();
      expect(this.story.get('state')).toEqual('rejected');
    });

    it('should restart', function() {
      this.story.restart();
      expect(this.story.get('state')).toEqual('started');
    });

  });

  describe('estimable', function() {

    it('should be estimable if it is a feature', function() {
      expect(this.story.estimable()).toBeTruthy();
    });

    it('should say if it is estimated or not', function() {
      expect(this.story.estimated()).toBeFalsy();
      this.story.set({estimate: 1});
      expect(this.story.estimated()).toBeTruthy();
    });

  });

  describe('class name', function() {

    it('should have a classes of story and story type', function() {
      this.story.set({estimate: 1});
      expect(this.story.className()).toEqual('story feature');
    });

    it('should have an unestimated class if unestimated', function() {
      expect(this.story.estimable()).toBeTruthy();
      expect(this.story.estimated()).toBeFalsy();
      expect(this.story.className()).toEqual('story feature unestimated');
    });

  });

});
