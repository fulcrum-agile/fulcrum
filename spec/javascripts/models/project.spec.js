describe('Project model', function() {

  beforeEach(function() {
    var Story = Backbone.Model.extend({
      name: 'story',
      fetch: function() {},
      position: function() {}
    });
    this.story = new Story({id: 456});

    this.project = new Project({
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
      expect(this.project.stories.url).toEqual('/projects/999/stories')
      // Sets up a reference on the collection to itself
      expect(this.project.stories.project).toBe(this.project);
    });

    it('should set up a user collection', function() {
      expect(this.project.users).toBeDefined();
      expect(this.project.users.url).toEqual('/projects/999/users')
      // Sets up a reference on the collection to itself
      expect(this.project.users.project).toBe(this.project);
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

  });


  describe("start date", function() {

    it("should return the start date", function() {
      // Date is a Monday, and day 1 is Monday
      this.project.set({start_date: "2011/07/25",iteration_start_day: 1});
      expect(this.project.startDate()).toEqual(new Date("2011/07/25"));

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
      orig_date = Date;
      Date = sinon.stub().returns(fake_today);
      this.project.unset('start_date');
      expect(this.project.startDate()).toEqual(expected_date);
      Date = orig_date;
    });
  });
});
