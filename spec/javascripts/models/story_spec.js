describe('Fulcrum.Story', function() {

  beforeEach(function() {
    var Project = Backbone.Model.extend({
      name: 'project',
      defaults: {point_values: [0, 1, 2, 3]},
      users: { get: function() {} },
      current_user: { id: 999 },
      currentIterationNumber: function() { return 1; },
      getIterationNumberForDate: function() { return 999; }
    });
    var collection = {
      project: new Project({}), url: '/foo', remove: function() {},
      get: function() {}
    };
    var view = new Backbone.View();
    this.story = new Fulcrum.Story({
      id: 999, title: 'Test story', position: '2.45'
    });
    this.new_story = new Fulcrum.Story({
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

  });

  describe("events", function() {
    it("transitions from unscheduled", function() {
      this.story.set({state: "unscheduled"});
      expect(this.story.events()).toEqual(["start"]);
    });
    it("transitions from unstarted", function() {
      this.story.set({state: "unstarted"});
      expect(this.story.events()).toEqual(["start"]);
    });
    it("transitions from started", function() {
      this.story.set({state: "started"});
      expect(this.story.events()).toEqual(["finish"]);
    });
    it("transitions from finished", function() {
      this.story.set({state: "finished"});
      expect(this.story.events()).toEqual(["deliver"]);
    });
    it("transitions from delivered", function() {
      this.story.set({state: "delivered"});
      expect(this.story.events()).toEqual(["accept", "reject"]);
    });
    it("transitions from rejected", function() {
      this.story.set({state: "rejected"});
      expect(this.story.events()).toEqual(["restart"]);
    });
    it("has no transitions from accepted", function() {
      this.story.set({state: "accepted"});
      expect(this.story.events()).toEqual([]);
    });
  });

  describe("setAcceptedAt", function() {

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

    describe("when story is a feature", function() {
      beforeEach(function() {
        this.story.set({story_type: 'feature'});
      });
      it('should be estimable when not estimated', function() {
        sinon.stub(this.story, 'estimated').returns(false);
        expect(this.story.estimable()).toBeTruthy();
      });
      it('should not be estimable when estimated', function() {
        sinon.stub(this.story, 'estimated').returns(true);
        expect(this.story.estimable()).toBeFalsy();
      });
    });

  });

  describe('estimated', function() {

    it('should say if it is estimated or not', function() {
      this.story.unset('estimate');
      expect(this.story.estimated()).toBeFalsy();
      this.story.set({estimate: null});
      expect(this.story.estimated()).toBeFalsy();
      this.story.set({estimate: 0});
      expect(this.story.estimated()).toBeTruthy();
      this.story.set({estimate: 1});
      expect(this.story.estimated()).toBeTruthy();
    });

  });

  describe('point_values', function() {

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
      expect(this.story.column).toEqual('#chilly_bin');
      this.story.set({state: 'unstarted'});
      expect(this.story.column).toEqual('#backlog');
      this.story.set({state: 'started'});
      expect(this.story.column).toEqual('#in_progress');
      this.story.set({state: 'delivered'});
      expect(this.story.column).toEqual('#in_progress');
      this.story.set({state: 'rejected'});
      expect(this.story.column).toEqual('#in_progress');

      // If the story is accepted, but it's accepted_at date is within the
      // current iteration, it should be in the in_progress column, otherwise
      // it should be in the #done column
      sinon.stub(this.story, 'iterationNumber').returns(1);
      this.story.collection.project.currentIterationNumber = sinon.stub().returns(2);
      this.story.set({state: 'accepted'});
      expect(this.story.column).toEqual('#done');
      this.story.collection.project.currentIterationNumber.returns(1);
      this.story.setColumn();
      expect(this.story.column).toEqual('#in_progress');
    });
  });

  describe("clear", function() {

    it("should destroy itself and its view", function() {
      var model_spy = sinon.spy(this.story, "destroy");
      var view_spy = sinon.spy(this.story.view, "remove");

      this.story.clear();

      expect(model_spy).toHaveBeenCalled();
      expect(view_spy).toHaveBeenCalled();
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

    it("should get it's requester", function() {

      // Should return undefined if the story does not have an owner
      var stub = sinon.stub(this.story.collection.project.users, "get");
      var dummyUser = {};
      stub.withArgs(undefined).returns(undefined);
      stub.withArgs(999).returns(dummyUser);

      var requested_by = this.story.requested_by();
      expect(stub).toHaveBeenCalledWith(undefined);
      expect(requested_by).toBeUndefined();

      this.story.set({'requested_by_id': 999});
      requested_by = this.story.requested_by();
      expect(requested_by).toEqual(dummyUser);
      expect(stub).toHaveBeenCalledWith(999);
    });

    it("should return a readable created_at", function() {

      var timestamp = "2011/09/19 02:25:56 +0000";
      this.story.set({'created_at': timestamp});
      expect(this.story.created_at()).toBe(
        new Date(timestamp).format(this.story.timestampFormat)
      );

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
    it("should return true the story has a description", function() {

      expect(this.story.hasDetails()).toBeFalsy();

      this.story.set({description: "Test description"});

      expect(this.story.hasDetails()).toBeTruthy();

    });

    it("should return true if the story has saved notes", function() {

      expect(this.story.hasDetails()).toBeFalsy();
      this.story.hasNotes = sinon.stub().returns(true);
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

  describe("labels", function() {

    it("should return an empty array if labels undefined", function() {
      expect(this.story.get('labels')).toBeUndefined();
      expect(this.story.labels()).toEqual([]);
    });

    it("should return an array of labels", function() {
      this.story.set({labels: "foo,bar"});
      expect(this.story.labels()).toEqual(["foo","bar"]);
    });

    it("should remove trailing and leading whitespace when spliting labels", function() {
      this.story.set({labels: "foo , bar , baz"});
      expect(this.story.labels()).toEqual(["foo","bar","baz"]);
    });

  });

  describe("notes", function() {

    it("should default with an empty notes collection", function() {
      expect(this.story.notes.length).toEqual(0);
    });

    it("should set the right notes collection url", function() {
      expect(this.story.notes.url()).toEqual('/foo/999/notes');
    });

    it("should set a notes collection", function() {
      var story = new Fulcrum.Story({
        notes: [{"note":{"text": "Dummy note"}}]
      });

      expect(story.notes.length).toEqual(1);
    });

    describe("hasNotes", function() {

      it("returns true if it has saved notes", function() {
        expect(this.story.hasNotes()).toBeFalsy();
        this.story.notes.add({id: 999, note: "Test note"});
        expect(this.story.hasNotes()).toBeTruthy();
      });

      it("returns false if it has unsaved notes", function() {
        this.story.notes.add({note: "Unsaved note"});
        expect(this.story.hasNotes()).toBeFalsy();
      });

    });

  });

  describe('humanAttributeName', function() {

    beforeEach(function() {
      I18n = {t: sinon.stub()};
      I18n.t.withArgs('foo_bar').returns('Foo bar');
    });

    it("returns the translated attribute name", function() {
      expect(this.story.humanAttributeName('foo_bar')).toEqual('Foo bar');
    });

    it("strips of the id suffix", function() {
      expect(this.story.humanAttributeName('foo_bar_id')).toEqual('Foo bar');
    });
  });

});
