describe('Project model', function() {

  beforeEach(function() {
    var Story = Backbone.Model.extend({
      name: 'story',
      fetch: function() {},
      position: function() {},
      labels: function() { return []; }
    });
    this.story = new Story({id: 456});

    this.project = new Fulcrum.Project({
      id: 999, title: 'Test project', point_values: [0, 1, 2, 3],
      last_changeset_id: null, iteration_start_day: 1, iteration_length: 1
    });
    this.project.stories.add(this.story);
  });

  describe('when instantiated', function() {

    it('should exhibit attributes', function() {
      expect(this.project.get('point_values'))
        .toEqual([0, 1, 2, 3]);
    });

    it('should set up a story collection', function() {
      expect(this.project.stories).toBeDefined();
      expect(this.project.stories.url).toEqual('/projects/999/stories');
      // Sets up a reference on the collection to itself
      expect(this.project.stories.project).toBe(this.project);
    });

    it('should set up a user collection', function() {
      expect(this.project.users).toBeDefined();
      expect(this.project.users.url).toEqual('/projects/999/users');
      // Sets up a reference on the collection to itself
      expect(this.project.users.project).toBe(this.project);
    });

    it("should have a default velocity of 10", function() {
      expect(this.project.get('default_velocity')).toEqual(10);
    });

  });

  describe('url', function() {

    it('should have a url', function() {
      expect(this.project.url()).toEqual('/projects/999');
    });

  });

  describe('changesets', function() {

    it('should load changesets when last_changeset_id is changed', function() {
      var server = sinon.fakeServer.create();
      var spy = sinon.spy(this.project, 'handleChangesets');
      var changesets = [{"changeset":{"id":2,"story_id":456,"project_id":789}}];
      server.respondWith(
        "GET", "/projects/999/changesets?from=0&to=2", [
          200, {"Content-Type": "application/json"},
          JSON.stringify(changesets)
        ]
      );

      expect(this.project.get('last_changeset_id')).toBeNull();
      this.project.set({last_changeset_id: 2});

      expect(server.requests.length).toEqual(1);

      server.respond();

      expect(spy).toHaveBeenCalledWith(changesets);

      server.restore();
    });

    it("should reload changed stories from changesets", function() {

      var changesets = [{"changeset":{"id":123,"story_id":456,"project_id":789}}];
      var get_spy = sinon.spy(this.project.stories, 'get');
      var fetch_spy = sinon.spy(this.story, 'fetch');

      this.project.handleChangesets(changesets);

      expect(get_spy).toHaveBeenCalledWith(456);
      expect(fetch_spy).toHaveBeenCalled();

    });

    it("should load new stories from changesets", function() {

      var story_json = {"story":{"id":987,"title":"New changeset story"}};
      var server = sinon.fakeServer.create();
      server.respondWith(
        "GET", "/projects/999/stories/987", [
          200, {"Content-Type": "application/json"},
          JSON.stringify(story_json)
        ]
      );

      var changesets = [{"changeset":{"id":123,"story_id":987,"project_id":789}}];
      var get_spy = sinon.spy(this.project.stories, 'get');
      var add_spy = sinon.spy(this.project.stories, 'add');
      var initial_collection_length = this.project.stories.length;

      this.project.handleChangesets(changesets);

      expect(server.requests.length).toEqual(1);
      server.respond();

      expect(get_spy).toHaveBeenCalled();
      expect(add_spy).toHaveBeenCalled();
      expect(this.project.stories.length).toEqual(initial_collection_length + 1);
      expect(this.project.stories.get(987).get('title')).toEqual("New changeset story");

      server.restore();
    });


    it("should only reload a story once if present in multiple changesets", function() {

      var story_json = {"story":{"id":987,"title":"New changeset story"}};
      var server = sinon.fakeServer.create();
      server.respondWith(
        "GET", "/projects/999/stories/987", [
          200, {"Content-Type": "application/json"},
          JSON.stringify(story_json)
        ]
      );

      // This set of changes represents the same story modified twice.  It
      // should only be loaded once.
      var changesets = [
        {"changeset":{"id":1,"story_id":987,"project_id":789}},
        {"changeset":{"id":2,"story_id":987,"project_id":789}}
      ];

      this.project.handleChangesets(changesets);
      expect(server.requests.length).toEqual(1);
    });
  });


  describe("iterations", function() {

    it("should get the right iteration number for a given date", function() {
      // This is a Monday
      this.project.set({start_date: "2011/07/25"});

      var compare_date = new Date("2011/07/25");
      expect(this.project.getIterationNumberForDate(compare_date)).toEqual(1);

      compare_date = new Date("2011/08/01");
      expect(this.project.getIterationNumberForDate(compare_date)).toEqual(2);

      // With a 2 week iteration length, the date above will still be in
      // iteration 1
      this.project.set({iteration_length: 2});
      expect(this.project.getIterationNumberForDate(compare_date)).toEqual(1);
    });

    it("should return the current iteration number", function() {
      expect(this.project.currentIterationNumber()).toEqual(1);
    });

    it("should return the date for an iteration number", function() {

      // This is a Monday
      this.project.set({start_date: "2011/07/25"});

      expect(this.project.getDateForIterationNumber(1)).toEqual(new Date("2011/07/25"));
      expect(this.project.getDateForIterationNumber(5)).toEqual(new Date("2011/08/22"));

      this.project.set({iteration_length: 4});
      expect(this.project.getDateForIterationNumber(1)).toEqual(new Date("2011/07/25"));
      expect(this.project.getDateForIterationNumber(5)).toEqual(new Date("2011/11/14"));

      // Sunday
      this.project.set({iteration_start_day: 0});
      expect(this.project.getDateForIterationNumber(1)).toEqual(new Date("2011/07/24"));
      expect(this.project.getDateForIterationNumber(5)).toEqual(new Date("2011/11/13"));

      // Tuesday - This should evaluate to the Tuesday before the explicitly
      // set start date (Monday)
      this.project.set({iteration_start_day: 2});
      expect(this.project.getDateForIterationNumber(1)).toEqual(new Date("2011/07/19"));
      expect(this.project.getDateForIterationNumber(5)).toEqual(new Date("2011/11/08"));
    });

    it("should initialize with an array of iterations", function() {
      expect(this.project.iterations).toEqual([]);
    });

    it("should get all the done iterations", function() {
      var doneIteration = {
        get: sinon.stub().withArgs('column').returns('#done')
      };
      var inProgressIteration = {
        get: sinon.stub().withArgs('column').returns('#in_progress')
      };
      var backlogIteration = {
        get: sinon.stub().withArgs('column').returns('#backlog')
      };
      var chillyBinIteration = {
        get: sinon.stub().withArgs('column').returns('#chilly_bin')
      };

      this.project.iterations = [
        doneIteration, inProgressIteration, backlogIteration, chillyBinIteration
      ];

      expect(this.project.doneIterations()).toEqual([doneIteration]);
    });

  });


  describe("start date", function() {

    it("should return the start date", function() {
      // Date is a Monday, and day 1 is Monday
      this.project.set({start_date: "2011/09/12",iteration_start_day: 1});
      expect(this.project.startDate()).toEqual(new Date("2011/09/12"));

      // If the project start date has been explicitly set to a Thursday, but
      // the iteration_start_day is Monday, the start date should be the Monday
      // that immeadiatly preceeds the Thursday.
      this.project.set({start_date: "2011/07/28"});
      expect(this.project.startDate()).toEqual(new Date("2011/07/25"));

      // The same, but this time the iteration start day is 'after' the start
      // date day, in ordinal terms, e.g. iteration start date is a Saturday,
      // project start date is a Thursday.  The Saturday prior to the Thursday
      // should be returned.
      this.project.set({iteration_start_day: 6});
      expect(this.project.startDate()).toEqual(new Date("2011/07/23"));

      // If the project start date is not set, it should be considered as the
      // first iteration start day prior to today.
      // FIXME - Stubbing Date is not working
      var expected_date = new Date('2011/07/23');
      var fake_today = new Date('2011/07/29');
      // Stop JSHINT complaining about overriding Date
      /*global Date: true*/
      orig_date = Date;
      Date = sinon.stub().returns(fake_today);
      this.project.unset('start_date');
      expect(this.project.startDate()).toEqual(expected_date);
      Date = orig_date;
    });
  });

  describe("velocity", function() {

    it("returns the default velocity when done iterations are empty", function() {
      this.project.set({'default_velocity': 999});
      expect(this.project.velocity()).toEqual(999);
    });

    it("should return velocity", function() {
      var doneIterations = _.map([1,2,3,4,5], function(i) {
        return {points: sinon.stub().returns(i)};
      });
      var doneIterationsStub = sinon.stub(this.project, 'doneIterations');
      doneIterationsStub.returns(doneIterations);

      // By default, should take the average of the last 3 iterations,
      // (3 + 4 + 5) = 12 / 3 = 4
      expect(this.project.velocity()).toEqual(4);
    });

    it("should floor the velocity when it returns a fraction", function() {
      var doneIterations = _.map([3,2,2], function(i) {
        return {points: sinon.stub().returns(i)};
      });
      var doneIterationsStub = sinon.stub(this.project, 'doneIterations');
      doneIterationsStub.returns(doneIterations);

      // Should floor the result
      // (3 + 2 + 2) = 7 / 3 = 2.333333
      expect(this.project.velocity()).toEqual(2);
    });

    it("should return the velocity when few iterations are complete", function() {
      // Still calculate the average correctly if fewer than the expected
      // number of iterations have been completed.
      var doneIterations = _.map([3,1], function(i) {
        return {points: sinon.stub().returns(i)};
      });
      var doneIterationsStub = sinon.stub(this.project, 'doneIterations');
      doneIterationsStub.returns(doneIterations);

      expect(this.project.velocity()).toEqual(2);
    });

    it("should not return less than 1", function() {
      var doneIterations = _.map([0,0,0], function(i) {
        return {points: sinon.stub().returns(i)};
      });
      var doneIterationsStub = sinon.stub(this.project, 'doneIterations');
      doneIterationsStub.returns(doneIterations);

      expect(this.project.velocity()).toEqual(1);
    });

    describe("when velocity is not set", function() {
      describe("velocityIsFake", function() {
        it("should be false", function() {
          expect(this.project.velocityIsFake()).toBeFalsy();
        });
      });

      it("returns the default velocity", function() {
          this.project.set({'default_velocity': 99});
          expect(this.project.velocity()).toEqual(99);
      });
    });

    describe("when velocity is set to 20", function() {

      beforeEach(function() {
        this.project.velocity(20);
      });

      describe("velocityIsFake", function() {
        it("should be true", function() {
          expect(this.project.velocityIsFake()).toBeTruthy();
        });
      });

      it("returns 20", function() {
          expect(this.project.velocity()).toEqual(20);
      });
    });

    describe("when velocity is set to less than 1", function() {

      beforeEach(function() {
        this.project.velocity(0);
      });

      it("sets the velocity to 1", function() {
        expect(this.project.velocity()).toEqual(1);
      });

    });

    describe("when velocity is set to the same as the real value", function() {

      describe("velocity", function() {
        beforeEach(function() {
          this.project.set({'userVelocity': 20, velocityIsFake: true});
          this.project.calculateVelocity = function() { return 20; };
          this.project.velocity(20);
        });

        it("should unset userVelocity", function() {
          expect(this.project.get('userVelocity')).toBeUndefined();
        });

        it("should be false", function() {
          expect(this.project.velocityIsFake()).toBeFalsy();
        });
      });
    });

    describe("revertVelocity", function() {

      beforeEach(function() {
        this.project.set({userVelocity: 999, velocityIsFake: true});
      });

      it("unsets userVelocity", function() {
        this.project.revertVelocity();
        expect(this.project.get('userVelocity')).toBeUndefined();
      });

      it("sets velocityIsFake to false", function() {
        this.project.revertVelocity();
        expect(this.project.velocityIsFake()).toBeFalsy();
      });
    });

  });


  describe("appendIteration", function() {

    beforeEach(function() {
      this.iteration = {
        get: sinon.stub()
      };
    });

    it("should add the first iteration to the array", function() {
      var stub = sinon.stub(Fulcrum.Iteration, 'createMissingIterations');
      stub.returns([]);
      this.project.appendIteration(this.iteration);
      expect(_.last(this.project.iterations)).toEqual(this.iteration);
      expect(this.project.iterations.length).toEqual(1);
      stub.restore();
    });

    it("should create missing iterations if required", function() {
      var spy = sinon.spy(Fulcrum.Iteration, 'createMissingIterations');
      this.iteration.get.withArgs('number').returns(1);
      this.project.iterations.push(this.iteration);
      var iteration = {
        get: sinon.stub().withArgs('number').returns(5)
      };
      this.project.appendIteration(iteration, '#done');
      expect(spy).toHaveBeenCalledWith('#done', this.iteration, iteration);
      expect(this.project.iterations.length).toEqual(5);
      spy.restore();
    });

  });

  describe("columns", function() {

    it("should define the columns", function() {
      expect(this.project.columnIds).toEqual([
        '#done', '#in_progress', '#backlog', '#chilly_bin'
      ]);
    });

    it("should return the columns after a given column", function() {
      expect(this.project.columnsAfter('#done')).toEqual([
        '#in_progress', '#backlog', '#chilly_bin'
      ]);
      expect(this.project.columnsAfter('#in_progress')).toEqual([
        '#backlog', '#chilly_bin'
      ]);
      expect(this.project.columnsAfter('#backlog')).toEqual(['#chilly_bin']);
      expect(this.project.columnsAfter('#chilly_bin')).toEqual([]);

      var project = this.project;
      expect(function() {project.columnsAfter('#foobar');}).toThrow(
        "#foobar is not a valid column"
      );
    });

    it("should return the columns before a given column", function() {
      expect(this.project.columnsBefore('#done')).toEqual([]);
      expect(this.project.columnsBefore('#in_progress')).toEqual(['#done']);
      expect(this.project.columnsBefore('#backlog')).toEqual([
        '#done', '#in_progress'
      ]);
      expect(this.project.columnsBefore('#chilly_bin')).toEqual([
        '#done', '#in_progress', '#backlog'
      ]);

      var project = this.project;
      expect(function() {project.columnsBefore('#foobar');}).toThrow(
        "#foobar is not a valid column"
      );
    });

  });

  describe("rebuildIterations", function() {

    beforeEach(function() {
      this.project.stories.invoke = sinon.stub();
    });

    it("triggers a rebuilt-iterations event", function() {
      var stub = sinon.stub();
      this.project.on('rebuilt-iterations', stub);
      this.project.rebuildIterations();
      expect(stub).toHaveBeenCalled();
    });

  });

});
