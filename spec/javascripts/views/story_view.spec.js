describe('StoryView', function() {

  beforeEach(function() {
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

  });

  describe("id", function() {

    it("should have an id", function() {
      expect(this.view.id).toEqual(this.view.model.id);
      expect($(this.view.el)).toHaveId(this.view.model.id);
    });

  });

  describe("story_type", function(){
    it('should have limited controls if it is changed to a release', function() {
      this.story.set({editing: true});
      expect($(this.view.el).find('select[name="state"]').is(':enabled')).toBeTruthy();
      expect($(this.view.el).find('select[name="estimate"]').is(':enabled')).toBeTruthy();

      $(this.view.el).find('select[name="story_type"]').val('release').change();
      // Should disable estimate field
      expect($(this.view.el).find('select[name="estimate"]').attr('disabled')).toBeTruthy();
      // Should limit state options
      expect($(this.view.el).find('select[name="state"]').find('option[value="unscheduled"]').length).toBeFalsy();
      expect($(this.view.el).find('select[name="state"]').find('option[value="unstarted"]').length).toBeTruthy();
      expect($(this.view.el).find('select[name="state"]').find('option[value="started"]').length).toBeFalsy();
      expect($(this.view.el).find('select[name="state"]').find('option[value="finished"]').length).toBeFalsy();
      expect($(this.view.el).find('select[name="state"]').find('option[value="delivered"]').length).toBeFalsy();
      expect($(this.view.el).find('select[name="state"]').find('option[value="accepted"]').length).toBeTruthy();
      expect($(this.view.el).find('select[name="state"]').find('option[value="rejected"]').length).toBeFalsy();
    });

    it('should have limited controls if it is a release on render', function() {
      this.story.set({editing: true});
      $(this.view.el).find('select[name="story_type"]').val('release').change();
      this.view.render();
      expect($(this.view.el).find('select[name="estimate"]').attr('disabled')).toBeTruthy();

      expect($(this.view.el).find('select[name="state"]').find('option[value="unscheduled"]').length).toBeFalsy();
      expect($(this.view.el).find('select[name="state"]').find('option[value="unstarted"]').length).toBeTruthy();
    });

    it('should get back full control when changed back', function() {
      this.story.set({editing: true});
      $(this.view.el).find('select[name="story_type"]').val('release').change();
      this.view.render();
      // Sanity check
      expect($(this.view.el).find('select[name="estimate"]').attr('disabled')).toBeTruthy();

      $(this.view.el).find('select[name="story_type"]').val('feature').change();
      expect($(this.view.el).find('select[name="estimate"]').attr('disabled')).toBe(false);
      expect($(this.view.el).find('select[name="state"]').find('option[value="unscheduled"]').length).toBe(1);
      expect($(this.view.el).find('select[name="state"]').find('option[value="unstarted"]').length).toBe(1);
    });

    it('should restore original value when changed back', function() {
      this.story.set({editing: true});
      $(this.view.el).find('select[name="estimate"]').val('2').change();
      $(this.view.el).find('select[name="story_type"]').val('release').change();
      this.view.render();
      // Sanity check
      expect($(this.view.el).find('select[name="estimate"]').attr('disabled')).toBeTruthy();

      $(this.view.el).find('select[name="story_type"]').val('feature').change();
      expect($(this.view.el).find('select[name="estimate"]').val()).toBe('2');
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

});
