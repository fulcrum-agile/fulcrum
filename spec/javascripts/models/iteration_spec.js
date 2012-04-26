describe("iteration", function() {

  beforeEach(function() {
    this.iteration = new Fulcrum.Iteration({});
  });

  describe("initialize", function() {

    it("should assign stories if passed", function() {
      var stories = [1,2,3];
      var iteration = new Fulcrum.Iteration({'stories': stories});
      expect(iteration.get('stories')).toEqual(stories);
    });

  });

  describe("defaults", function() {

    it("should have an empty array of stories", function() {
      expect(this.iteration.get('stories')).toEqual([]);
    });

  });

  describe("points", function() {

    beforeEach(function() {
      var Story = Backbone.Model.extend({name: 'story'});
      this.stories = [
        new Story({estimate: 2, story_type: 'feature'}),
        new Story({estimate: 3, story_type: 'feature', state: 'accepted'}),
        new Story({estimate: 3, story_type: 'bug', state: 'accepted'}) // Only features count
                                                                       // towards velocity
      ];
      this.iteration.set({stories: this.stories});
    });

    it("should calculate its points", function() {
      expect(this.iteration.points()).toEqual(5);
    });

    it("should return 0 for points if it has no stories", function() {
      this.iteration.unset('stories');
      expect(this.iteration.points()).toEqual(0);
    });

    it("should report how many points it overflows by", function() {
      // Should return 0
      this.iteration.set({'maximum_points':2});
      var pointsStub = sinon.stub(this.iteration, 'points');

      // Should return 0 if the iteration points are less than maximum_points
      pointsStub.returns(1);
      expect(this.iteration.overflowsBy()).toEqual(0);

      // Should return 0 if the iteration points are equal to maximum_points
      pointsStub.returns(2);
      expect(this.iteration.overflowsBy()).toEqual(0);

      // Should return the difference if iteration points are greater than
      // maximum_points
      pointsStub.returns(5);
      expect(this.iteration.overflowsBy()).toEqual(3);
    });

    it("should report how many accepted points it has", function() {
      expect(this.iteration.acceptedPoints()).toEqual(3);
    });

  });

  describe("filling backlog iterations", function() {

    it("should return how many points are available", function() {
      var pointsStub = sinon.stub(this.iteration, "points");
      pointsStub.returns(3);

      this.iteration.set({'maximum_points': 5});
      expect(this.iteration.availablePoints()).toEqual(2);
    });

    it("should always accept chores bugs and releases", function() {
      var stub = sinon.stub();
      var story = {get: stub};

      stub.withArgs('story_type').returns('chore');
      expect(this.iteration.canTakeStory(story)).toBeTruthy();
      stub.withArgs('story_type').returns('bug');
      expect(this.iteration.canTakeStory(story)).toBeTruthy();
      stub.withArgs('story_type').returns('release');
      expect(this.iteration.canTakeStory(story)).toBeTruthy();
    });

    it("should not accept anything when isFull is true", function() {
      var stub = sinon.stub();
      var story = {get: stub};

      this.iteration.isFull = true;

      stub.withArgs('story_type').returns('chore');
      expect(this.iteration.canTakeStory(story)).toBeFalsy();
      stub.withArgs('story_type').returns('bug');
      expect(this.iteration.canTakeStory(story)).toBeFalsy();
      stub.withArgs('story_type').returns('release');
      expect(this.iteration.canTakeStory(story)).toBeFalsy();
    });

    it("should accept a feature if there are enough free points", function() {
      var availablePointsStub = sinon.stub(this.iteration, "availablePoints");
      availablePointsStub.returns(3);
      var pointsStub = sinon.stub(this.iteration, 'points');
      pointsStub.returns(1);

      var stub = sinon.stub();
      var story = {get: stub};

      stub.withArgs('story_type').returns('feature');
      stub.withArgs('estimate').returns(3);

      expect(this.iteration.canTakeStory(story)).toBeTruthy();

      // Story is too big to fit in iteration
      stub.withArgs('estimate').returns(4);
      expect(this.iteration.canTakeStory(story)).toBeFalsy();
    });

    // Each iteration should take at least one feature
    it("should always take at least one feature no matter how big", function() {
      var availablePointsStub = sinon.stub(this.iteration, "availablePoints");
      availablePointsStub.returns(1);

      var stub = sinon.stub();
      var story = {get: stub};
      stub.withArgs('story_type').returns('feature');
      stub.withArgs('estimate').returns(2);

      expect(this.iteration.points()).toEqual(0);
      expect(this.iteration.canTakeStory(story)).toBeTruthy();
    });


  });

  describe("isFull flag", function() {

    it("should default to false", function() {
      expect(this.iteration.isFull).toEqual(false);
    });

    it("should be set to true once canTakeStory has returned false", function() {
      var stub = sinon.stub();
      var story = {get: stub};

      this.iteration.availablePoints = sinon.stub();
      this.iteration.availablePoints.returns(0);
      this.iteration.points = sinon.stub();
      this.iteration.points.returns(1);

      stub.withArgs('story_type').returns('feature');
      stub.withArgs('estimate').returns(1);

      expect(this.iteration.isFull).toEqual(false);
      expect(this.iteration.canTakeStory(story)).toBeFalsy();
      expect(this.iteration.isFull).toEqual(true);
    });

  });

  describe("createMissingIterations", function() {

    beforeEach(function() {
      this.start = new Fulcrum.Iteration({'number': 1});
    });

    it("should create a range of iterations", function() {
      var end = new Fulcrum.Iteration({'number': 5});
      var iterations = Fulcrum.Iteration.createMissingIterations('#done', this.start, end);
      expect(iterations.length).toEqual(3);
    });

    it("should return an empty array when there is no gap between start and end", function() {
      var end   = new Fulcrum.Iteration({'number': 2});
      var iterations = Fulcrum.Iteration.createMissingIterations('#done', this.start, end);
      expect(iterations.length).toEqual(0);
    });

    it("should raise an exception if end number is less than or equal to start", function() {
      var end   = new Fulcrum.Iteration({'number': 1});
      var that = this;
      expect(function() {
        Fulcrum.Iteration.createMissingIterations('#done', that.start, end);
      }).toThrow("end iteration number:1 must be greater than start iteration number:2");
    });

    it("should return an empty array when start is undefined and end is number 1", function() {
      var end   = new Fulcrum.Iteration({'number': 1});
      var iterations = Fulcrum.Iteration.createMissingIterations('#done', undefined, end);
      expect(iterations.length).toEqual(0);
    });

    it("should return a range of iterations when start is undefined", function() {
      var end   = new Fulcrum.Iteration({'number': 5});
      var iterations = Fulcrum.Iteration.createMissingIterations('#done', undefined, end);
      expect(iterations.length).toEqual(4);
      expect(_.first(iterations).get('number')).toEqual(1);
    });

    it("should return an empty array when start is undefined and end is number 1", function() {
      var end   = new Fulcrum.Iteration({'number': 1});
      var iterations = Fulcrum.Iteration.createMissingIterations('#done', undefined, end);
      expect(iterations.length).toEqual(0);
    });

    it("should return a range of iterations when start is undefined", function() {
      var end   = new Fulcrum.Iteration({'number': 5});
      var iterations = Fulcrum.Iteration.createMissingIterations('#done', undefined, end);
      expect(iterations.length).toEqual(4);
      expect(_.first(iterations).get('number')).toEqual(1);
    });

  });

  describe("startDate", function() {

    it("should return the start date", function() {
      var startDate = new Date('2011/09/26');
      var stub = sinon.stub();
      stub.returns(startDate);
      this.iteration.project = { getDateForIterationNumber: stub };

      expect(this.iteration.startDate()).toEqual(startDate);
      expect(stub).toHaveBeenCalledWith(this.iteration.get('number'));
    });

  });

  describe("stories", function() {

    beforeEach(function() {
      var Story = Backbone.Model.extend({name: 'story'});
      this.acceptedStory = new Story({state: 'accepted'});
      this.finishedStory = new Story({state: 'finished'});
      this.unstartedStory = new Story({state: 'unstarted'});
      var stories = [
        this.unstartedStory, this.acceptedStory, this.finishedStory
      ];
      this.iteration.set({stories: stories});
    });

    it("returns the stories in the order they were added by default", function() {
      expect(this.iteration.stories()).toEqual([
        this.unstartedStory, this.acceptedStory, this.finishedStory
      ]);
    });

    it("returns the stories accepted first if in progress iteration", function() {
      this.iteration.set({column:'#in_progress'});
      var stories = this.iteration.stories();
      expect(stories.length).toEqual(3);
      expect(stories[0]).toEqual(this.acceptedStory);
    });

    it("returns stories with a given state", function() {
      expect(this.iteration.storiesWithState('accepted')).toEqual([this.acceptedStory]);
    });

    it("returns stories except a given state", function() {
      expect(this.iteration.storiesExceptState('accepted')).toEqual([this.unstartedStory, this.finishedStory]);
    });
  });

});
