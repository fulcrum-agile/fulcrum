describe('StoryView', function() {

  beforeEach(function() {
    window.projectView = {
      availableTags: []
    };
    var Story = Backbone.Model.extend({
      name: 'story', defaults: {story_type: 'feature'},
      estimable: function() { return true; },
      estimated: function() { return false; },
      point_values: function() { return [0,1,2]; },
      hasErrors: function() { return false; },
      errorsOn: function() { return false; },
      url: '/path/to/story',
      collection: { project: { users: { forSelect: function() {return [];} } } },
      start: function() {},
      setAcceptedAt: sinon.spy()
      //moveAfter: function() {},
      //moveBefore: function() {}
    });
    this.story = new Story({id: 999, title: 'Story'});
    this.new_story = new Story({title: 'New Story'});
    this.view = new StoryView({
      model: this.story
    });
    this.new_story_view = new StoryView({
      model: this.new_story
    });

    this.server = sinon.fakeServer.create();
  });

  afterEach(function() {
    this.server.restore();
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

    it("should have the story state class", function() {
      expect($(this.view.el)).toHaveClass('unestimated');
      this.view.model.set({state: 'accepted'});
      expect($(this.view.el)).toHaveClass('accepted');
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

    it("should reload after cancel if there were existing errors", function() {
      this.story.set({errors:true});
      expect(this.story.get('errors')).toEqual(true);
      sinon.stub(this.story, "hasErrors").returns(true);
      var spy = sinon.spy(this.story, "fetch");
      this.view.cancelEdit();
      expect(spy).toHaveBeenCalled();
      expect(this.story.get('errors')).toBeUndefined();
    });

  });

  describe("save edit", function() {

    it("should call save", function() {
      this.server.respondWith(
        "PUT", "/path/to/story", [
          200, {"Content-Type": "application/json"},
          '{"story":{"title":"Story title"}}'
        ]
      );
      this.story.set({editing: true});
      this.view.saveEdit();
      expect(this.story.get('editing')).toBeTruthy();
      expect(this.server.requests.length).toEqual(1);

      // editing should be set to false when save is successful
      this.server.respond();

      expect(this.story.get('editing')).toBeFalsy();
    });

    it("should set editing when errors occur", function() {
      this.server.respondWith(
        "PUT", "/path/to/story", [
          422, {"Content-Type": "application/json"},
          '{"story":{"errors":{"title":["cannot be blank"]}}}'
        ]
      );

      this.view.saveEdit();
      expect(this.server.responses.length).toEqual(1);
      expect(this.server.responses[0].method).toEqual("PUT");
      expect(this.server.responses[0].url).toEqual("/path/to/story");

      this.server.respond();

      expect(this.story.get('editing')).toBeTruthy();
      expect(this.story.get('errors').title[0]).toEqual("cannot be blank");
    });

    it("should disable all form controls on submit", function() {
      this.server.respondWith(
        "PUT", "/path/to/story", [
          200, {"Content-Type": "application/json"},
          '{"story":{"title":"Story title"}}'
        ]
      );

      var disable_spy = sinon.spy(this.view, 'disableForm');
      var enable_spy = sinon.spy(this.view, 'enableForm');

      this.story.set({editing: true});
      this.view.saveEdit();

      expect(disable_spy).toHaveBeenCalled();
      expect(enable_spy).not.toHaveBeenCalled();
      expect($(this.view.el).find('img.collapse').attr('src')).toEqual('/images/throbber.gif');

      this.server.respond();

      expect(enable_spy).toHaveBeenCalled();
    });

    it('should disable state transition buttons on click', function() {
      this.server.respondWith(
        "PUT", "/path/to/story", [
          200, {"Content-Type": "application/json"},
          '{"story":{"state":"started"}}'
        ]
      );

      var ev = { target: { value : 'start' } };
      this.view.transition(ev);

      expect(this.view.saveInProgress).toBeTruthy();

      this.server.respond();

      expect(this.view.saveInProgress).toBeFalsy();
    });

    it('should disable estimate buttons on click', function() {
      this.server.respondWith(
        "PUT", "/path/to/story", [
          200, {"Content-Type": "application/json"},
          '{"story":{"estimate":"1"}}'
        ]
      );

      var ev = { target: { value : '1' } };
      this.view.estimate(ev);

      expect(this.view.saveInProgress).toBeTruthy();

      this.server.respond();

      expect(this.view.saveInProgress).toBeFalsy();
    });

    it("should call setAcceptedAt on the story", function() {
      this.view.saveEdit();
      expect(this.story.setAcceptedAt).toHaveBeenCalledOnce();
    });
  });

  describe("expand collapse controls", function() {

    it("should not show the collapse control if its a new story", function() {
      this.new_story.set({editing: true});

      expect($(this.new_story_view.el)).not.toContain('img.collapse');
    });

  });

  describe("sorting", function() {

    beforeEach(function() {
      this.story.collection.length = 1;
      this.story.collection.columns = function() {return [];};
      this.story.collection.project.columnsBefore = sinon.stub();
      this.story.collection.project.columnsAfter = sinon.stub();
    });

    it("sets state to unstarted if dropped on the backlog column", function() {

      this.story.set({'state':'unscheduled'});

      var html = $('<td id="backlog"><div id="1"></div></td>');
      var ev = {target: html.find('#1')};

      this.view.sortUpdate(ev);

      expect(this.story.get('state')).toEqual("unstarted");
    });

    it("sets state to unscheduled if dropped on the chilly_bin column", function() {

      this.story.set({'state':'unstarted'});

      var html = $('<td id="chilly_bin"><div id="1"></div></td>');
      var ev = {target: html.find('#1')};

      this.view.sortUpdate(ev);

      expect(this.story.get('state')).toEqual("unscheduled");
    });

    it("should move after the previous story in the column", function() {
      var html = $('<div id="1" class="story"></div><div id="2" class="story"></div>');
      var ev = {target: html[1]};

      this.story.moveAfter = sinon.spy();
      this.view.sortUpdate(ev);

      expect(this.story.moveAfter).toHaveBeenCalledWith("1");
    });

    it("should move before the next story in the column", function() {
      var html = $('<div id="1" class="story"></div><div id="2" class="story"></div>');
      var ev = {target: html[0]};

      this.story.moveBefore = sinon.spy();
      this.view.sortUpdate(ev);

      expect(this.story.moveBefore).toHaveBeenCalledWith("2");
    });

    it("should move before the next story in the column", function() {
      var html = $('<div id="foo"></div><div id="1" class="story"></div><div id="2" class="story"></div>');
      var ev = {target: html[1]};

      this.story.moveBefore = sinon.spy();
      this.view.sortUpdate(ev);

      expect(this.story.moveBefore).toHaveBeenCalledWith("2");
    });

    it("should move into an empty chilly bin", function() {
      var html = $('<td id="backlog"><div id="1"></div></td><td id="chilly_bin"><div id="2"></div></td>');
      var ev = {target: html.find('#2')};

      this.story.moveAfter = sinon.spy();
      this.view.sortUpdate(ev);

      expect(this.story.get('state')).toEqual('unscheduled');
    });

  });

  describe("hover box placement", function() {

    it("should return right if element is in the left half of the page", function() {
      var positionStub = sinon.stub(jQuery.fn, 'position');
      var widthStub = sinon.stub(jQuery.fn, 'width');
      positionStub.returns({'left': 25, 'top': 25});
      widthStub.returns(100);
      expect(this.view.hoverBoxPlacement()).toEqual('right');
      positionStub.restore();
      widthStub.restore();
    });

    it("should return left if element is in the right half of the page", function() {
      var positionStub = sinon.stub(jQuery.fn, 'position');
      var widthStub = sinon.stub(jQuery.fn, 'width');
      positionStub.returns({'left': 75, 'top': 75});
      widthStub.returns(100);
      expect(this.view.hoverBoxPlacement()).toEqual('left');
      positionStub.restore();
      widthStub.restore();
    });

  });
  describe("labels", function() {

    it("should initialize tagit on edit", function() {
      var spy = sinon.spy(jQuery.fn, 'tagit');
      this.new_story.set({editing: true});
      expect(spy).toHaveBeenCalled();
      spy.restore();
    });

  });

});
