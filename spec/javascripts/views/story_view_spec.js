describe('Fulcrum.StoryView', function() {

  beforeEach(function() {
    window.projectView = {
      availableTags: []
    };
    window.md = { makeHtml: sinon.stub() };
    var Note = Backbone.Model.extend({
      name: 'note',
      humanAttributeName: sinon.stub()
    });
    var NotesCollection = Backbone.Collection.extend({model: Note});
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
      humanAttributeName: sinon.stub(),
      setAcceptedAt: sinon.spy()
      //moveAfter: function() {},
      //moveBefore: function() {}
    });
    this.story = new Story({id: 999, title: 'Story'});
    this.new_story = new Story({title: 'New Story'});
    this.story.notes = this.new_story.notes = new NotesCollection();
    this.view = new Fulcrum.StoryView({
      model: this.story
    });
    this.new_story_view = new Fulcrum.StoryView({
      model: this.new_story
    });

    window.I18n = {t: sinon.stub()};

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
      expect($(this.view.el)).toHaveId("story-" + this.view.model.id);
    });

  });

  describe('startEdit', function() {
    beforeEach(function() {
      this.e = {};
      this.view.model.set = sinon.stub();
      this.view.removeHoverbox = sinon.stub();
    });

    describe('when event should expand story', function() {

      beforeEach(function() {
        this.view.eventShouldExpandStory = sinon.stub();
        this.view.eventShouldExpandStory.withArgs(this.e).returns(true);
      });

      it('sets the model attributes correctly', function() {
        this.view.startEdit(this.e);
        expect(this.view.model.set).toHaveBeenCalledWith({
          editing: true, editingDescription: false
        });
      });

      it('removes the hoverBox', function() {
        this.view.startEdit(this.e);
        expect(this.view.removeHoverbox).toHaveBeenCalled();
      });
    });
  });

  describe('eventShouldExpandStory', function() {

    beforeEach(function() {
      this.e = {target: '<input>'};
    });

    describe('when model is being edited', function() {

      beforeEach(function() {
        this.view.model.set({editing: true});
      });

      it("returns false", function() {
        expect(this.view.eventShouldExpandStory(this.e)).toBeFalsy();
      });

    });

    describe('when model is not being edited', function() {

      beforeEach(function() {
        this.view.model.set({editing: false});
      });

      describe('and e.target is an input', function() {
        it("returns false", function() {
          expect(this.view.eventShouldExpandStory(this.e)).toBeFalsy();
        });
      });

      describe('and e.target is not an input', function() {
        it("returns true", function() {
          this.e.target = '<span>';
          expect(this.view.eventShouldExpandStory(this.e)).toBeTruthy();
        });
      });

    });

  });

  describe("cancel edit", function() {

    it("should remove itself when edit cancelled if its new", function() {
      var view = new Fulcrum.StoryView({model: this.new_story});
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

      expect($(this.new_story_view.el)).not.toContain('a.collapse');
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

      var html = $('<td id="backlog"><div id="story-1"></div></td>');
      var ev = {target: html.find('#story-1')};

      this.view.sortUpdate(ev);

      expect(this.story.get('state')).toEqual("unstarted");
    });

    it("sets state to unstarted if dropped on the in_progress column", function() {

      this.story.set({'state':'unscheduled'});

      var html = $('<td id="in_progress"><div id="story-1"></div></td>');
      var ev = {target: html.find('#story-1')};

      this.view.sortUpdate(ev);

      expect(this.story.get('state')).toEqual("unstarted");
    });

    it("doesn't change state if not unscheduled and dropped on the in_progress column", function() {

      this.story.set({'state':'finished'});

      var html = $('<td id="in_progress"><div id="story-1"></div></td>');
      var ev = {target: html.find('#story-1')};

      this.view.sortUpdate(ev);

      expect(this.story.get('state')).toEqual("finished");
    });

    it("sets state to unscheduled if dropped on the chilly_bin column", function() {

      this.story.set({'state':'unstarted'});

      var html = $('<td id="chilly_bin"><div id="story-1"></div></td>');
      var ev = {target: html.find('#story-1')};

      this.view.sortUpdate(ev);

      expect(this.story.get('state')).toEqual("unscheduled");
    });

    it("should move after the previous story in the column", function() {
      var html = $('<div id="story-1" data-story-id="1" class="story"></div><div id="story-2" data-story-id="2" class="story"></div>');
      var ev = {target: html[1]};

      this.story.moveAfter = sinon.spy();
      this.view.sortUpdate(ev);

      expect(this.story.moveAfter).toHaveBeenCalledWith(1);
    });

    it("should move before the next story in the column", function() {
      var html = $('<div id="story-1" data-story-id="1" class="story"></div><div id="story-2" data-story-id="2" class="story"></div>');
      var ev = {target: html[0]};

      this.story.moveBefore = sinon.spy();
      this.view.sortUpdate(ev);

      expect(this.story.moveBefore).toHaveBeenCalledWith(2);
    });

    it("should move before the next story in the column", function() {
      var html = $('<div id="foo"></div><div id="story-1" data-story-id="1" class="story"></div><div id="story-2" data-story-id="2" class="story"></div>');
      var ev = {target: html[1]};

      this.story.moveBefore = sinon.spy();
      this.view.sortUpdate(ev);

      expect(this.story.moveBefore).toHaveBeenCalledWith(2);
    });

    it("should move into an empty chilly bin", function() {
      var html = $('<td id="backlog"><div id="story-1" data-story-id="1"></div></td><td id="chilly_bin"><div id="story-2" data-story-id="2"></div></td>');
      var ev = {target: html.find('#story-2')};

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

  describe("notes", function() {

    it("binds change:notes to renderNotesCollection()", function() {
      var spy = sinon.spy(this.story, 'bind');
      var view = new Fulcrum.StoryView({model: this.story});
      expect(spy).toHaveBeenCalledWith('change:notes', view.renderNotesCollection);
    });

    it("binds change:notes to addEmptyNote()", function() {
      var spy = sinon.spy(this.story, 'bind');
      var view = new Fulcrum.StoryView({model: this.story});
      expect(spy).toHaveBeenCalledWith('change:notes', view.addEmptyNote);
    });

    it("adds a blank note to the end of the notes collection", function() {
      this.view.model.notes.reset();
      expect(this.view.model.notes.length).toEqual(0);
      this.view.addEmptyNote();
      expect(this.view.model.notes.length).toEqual(1);
      expect(this.view.model.notes.last().isNew()).toBeTruthy();
    });

    it("doesn't add a blank note if the story is new", function() {
      var stub = sinon.stub(this.view.model, 'isNew');
      stub.returns(true);
      this.view.model.notes.reset();
      expect(this.view.model.notes.length).toEqual(0);
      this.view.addEmptyNote();
      expect(this.view.model.notes.length).toEqual(0);
    });

    it("doesn't add a blank note if there is already one", function() {
      this.view.model.notes.last = sinon.stub().returns({
        isNew: sinon.stub().returns(true)
      });
      expect(this.view.model.notes.last().isNew()).toBeTruthy();
      var oldLength = this.view.model.notes.length;
      this.view.addEmptyNote();
      expect(this.view.model.notes.length).toEqual(oldLength);
    });

  });

  describe("description", function() {

    beforeEach(function() {
      this.view.model.set({editing: true});
    });

    afterEach(function() {
      this.view.model.set({editing: false});
    });

    it("is text area when story is new", function() {
      this.view.model.isNew = sinon.stub().returns(true);
      this.view.render();
      expect(this.view.$('textarea[name="description"]').length).toEqual(1);
      expect(this.view.$('div.description').length).toEqual(0);
      expect(this.view.$('input#edit-description').length).toEqual(0);
    });

    it("isn't text area when story isn't new", function() {
      this.view.model.isNew = sinon.stub().returns(false);
      this.view.render();
      expect(this.view.$('textarea[name="description"]').length).toEqual(0);
      expect(this.view.$('div.description').length).toEqual(1);
      expect(this.view.$('input#edit-description').length).toEqual(1);
    });

    it('is a text area after #edit-description is clicked', function() {
      this.view.model.isNew = sinon.stub().returns(false);
      this.view.editDescription();
      expect(this.view.model.get('editingDescription')).toBeTruthy();
    });

  });

  describe("makeFormControl", function() {

    beforeEach(function() {
      this.div = {};
      this.view.make = sinon.stub().returns(this.div);
    });

    it("calls make('div')", function() {
      this.view.makeFormControl();
      expect(this.view.make).toHaveBeenCalled();
    });

    it("returns the div", function() {
      expect(this.view.makeFormControl()).toBe(this.div);
    });

    it("invokes its callback", function() {
      var callback = sinon.stub();
      this.view.makeFormControl(callback);
      expect(callback).toHaveBeenCalledWith(this.div);
    });

    describe("when passed an object", function() {

      beforeEach(function() {
        this.content = {name: "foo", label: "Foo", control: "bar"};
        this.appendSpy = sinon.spy(jQuery.fn, 'append');
      });

      afterEach(function() {
        this.appendSpy.restore();
      });

      it("creates a label", function() {
        var label = '<label for="foo">Foo</label>';
        var stub = sinon.stub(this.view, 'label').withArgs('foo').returns(label);
        this.view.makeFormControl(this.content);
        expect(this.appendSpy).toHaveBeenCalledWith(label);
        expect(this.appendSpy).toHaveBeenCalledWith('<br/>');
      });

      it("appends the control", function() {
        this.view.makeFormControl(this.content);
        expect(this.appendSpy).toHaveBeenCalledWith(this.content.control);
      });

    });
  });
});
