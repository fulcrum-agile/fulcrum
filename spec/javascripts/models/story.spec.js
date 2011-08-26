describe('Story model', function() {

  beforeEach(function() {
    var Project = Backbone.Model.extend({
      name: 'project',
      defaults: {point_values: [0, 1, 2, 3]},
      users: { get: function() {} },
      current_user: { id: 999 }
    });
    var collection = {
      project: new Project(), url: '/foo', remove: function() {},
      get: function() {}
    }
    var view = new Backbone.View;
    this.story = new Story({
      id: 999, title: 'Test story', position: '2.45'
    });
    this.new_story = new Story({
      title: 'New story'
    });
    this.story.collection = this.new_story.collection = collection;
    this.story.view = this.new_story.view = view;

    this.server = sinon.fakeServer.create();
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

    it("should set accepted at to today's date when accepted", function() {
      var today = new Date();
      today.setHours(0);
      today.setMinutes(0);
      today.setSeconds(0);
      today.setMilliseconds(0);
      expect(this.story.get('accepted_at')).toBeUndefined();
      this.story.accept();
      expect(new Date(this.story.get('accepted_at'))).toEqual(today);
    });

    it("should not set accepted at when accepted if already set", function() {
      this.story.set({accepted_at: "2001/01/01"});
      this.story.accept();
      expect(this.story.get('accepted_at')).toEqual("2001/01/01");
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

    it('should known about its valid points values', function() {
      expect(this.story.point_values()).toEqual([0, 1, 2, 3]);
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

  describe('position', function() {

    it('should get position as a float', function() {
      expect(this.story.position()).toEqual(2.45);
    });

  });

  describe('column', function() {
    it('should return the right column', function() {
      this.story.set({state: 'unscheduled'});
      expect(this.story.column()).toEqual('#chilly_bin');
      this.story.set({state: 'unstarted'});
      expect(this.story.column()).toEqual('#backlog');
      this.story.set({state: 'started'});
      expect(this.story.column()).toEqual('#in_progress');
      this.story.set({state: 'delivered'});
      expect(this.story.column()).toEqual('#in_progress');
      this.story.set({state: 'rejected'});
      expect(this.story.column()).toEqual('#in_progress');

      // If the story is accepted, but it's accepted_at date is within the
      // current iteration, it should be in the in_progress column, otherwise
      // it should be in the #done column
      sinon.stub(this.story, 'iterationNumber').returns(1);
      this.story.collection.project.currentIterationNumber = sinon.stub().returns(2);
      this.story.set({state: 'accepted'});
      expect(this.story.column()).toEqual('#done');
      this.story.collection.project.currentIterationNumber.returns(1);
      expect(this.story.column()).toEqual('#in_progress');
    });
  });

  describe("clear", function() {

    it("should destroy itself and its view", function() {
      var model_spy = sinon.spy(this.story, "destroy");
      var view_spy = sinon.spy(this.story.view, "remove");
      var collection_spy = sinon.spy(this.story.collection, "remove");

      this.story.clear();

      expect(model_spy).toHaveBeenCalled();
      expect(view_spy).toHaveBeenCalled();
      expect(collection_spy).toHaveBeenCalled();
    });

    it("should not call destroy if its a new object", function() {
      var spy = sinon.spy(this.new_story, 'destroy');
      var view_spy = sinon.spy(this.new_story.view, "remove");
      var collection_spy = sinon.spy(this.new_story.collection, "remove");

      this.new_story.clear();

      expect(spy).not.toHaveBeenCalled();
      expect(view_spy).toHaveBeenCalled();
      expect(collection_spy).toHaveBeenCalled();
    });

  });

  describe("errors", function() {

    it("should record errors", function() {
      expect(this.story.hasErrors()).toBeFalsy();
      expect(this.story.errorsOn('title')).toBeFalsy();

      this.story.set({errors: {
        title: ["cannot be blank", "needs to be better"],
        estimate: ["is helluh unrealistic"]
      }});

      expect(this.story.hasErrors()).toBeTruthy();
      expect(this.story.errorsOn('title')).toBeTruthy();
      expect(this.story.errorsOn('position')).toBeFalsy();

      expect(this.story.errorMessages())
        .toEqual("title cannot be blank, title needs to be better, estimate is helluh unrealistic");
    });

  });

  describe("users", function() {

    it("should get it's owner", function() {

      // Should return undefined if the story does not have an owner
      var spy = sinon.spy(this.story.collection.project.users, "get");
      var owned_by = this.story.owned_by();
      expect(spy).toHaveBeenCalledWith(undefined);
      expect(owned_by).toBeUndefined();

      this.story.set({'owned_by_id': 999});
      owned_by = this.story.owned_by();
      expect(spy).toHaveBeenCalledWith(999);
    });

    it("should be assigned to the current user when started", function() {

      expect(this.story.get('state')).toEqual('unscheduled');
      expect(this.story.owned_by()).toBeUndefined();

      this.story.set({state: 'started'});

      expect(this.story.get('owned_by_id')).toEqual(999);
    });

  });


  describe("details", function() {

    // If the story has details other than the title, e.g. description
    it("should return if the story has details", function() {

      expect(this.story.hasDetails()).toBeFalsy();

      this.story.set({description: "Test description"});

      expect(this.story.hasDetails()).toBeTruthy();

    });
  });


  describe("iterations", function() {

    it("should return the iteration number for an accepted story", function() {
      this.story.collection.project.getIterationNumberForDate = sinon.stub().returns(999);
      this.story.set({accepted_at: "2011/07/25", state: "accepted"});
      expect(this.story.iterationNumber()).toEqual(999);
    });

  });

});
