describe("Note", function() {

  beforeEach(function() {
    this.note = new Fulcrum.Note({});
  });

  describe("user", function() {

    beforeEach(function() {
      this.user = {};
      this.usersCollectionStub = sinon.stub();
      this.usersCollectionStub.withArgs(999).returns(this.user);
      this.project = {users: {get: this.usersCollectionStub}};
      this.note.set({user_id: 999});
      this.note.collection = {story: {collection: {project: this.project}}};
    });

    it("returns the author", function() {
      expect(this.note.user()).toEqual(this.user);
      expect(this.usersCollectionStub).toHaveBeenCalledWith(999);
    });

    it("returns the name of the user", function() {
      this.user.get = sinon.stub().withArgs('name').returns('User Name');
      expect(this.note.userName()).toEqual('User Name');
    });

    it("returns a placeholder when the user is null", function() {
      this.usersCollectionStub.withArgs(999).returns(null);
      expect(this.note.userName()).toEqual('Author unknown');
    });

  });

  describe("errors", function() {

    it("should record errors", function() {
      expect(this.note.hasErrors()).toBeFalsy();
      expect(this.note.errorsOn('note')).toBeFalsy();

      this.note.set({errors: {
        note: ["cannot be blank", "needs to be better"]
      }});

      expect(this.note.hasErrors()).toBeTruthy();
      expect(this.note.errorsOn('note')).toBeTruthy();

      expect(this.note.errorMessages())
        .toEqual("note cannot be blank, note needs to be better");
    });

  });

  describe('humanAttributeName', function() {

    beforeEach(function() {
      I18n = {t: sinon.stub()};
      I18n.t.withArgs('foo_bar').returns('Foo bar');
    });

    it("returns the translated attribute name", function() {
      expect(this.note.humanAttributeName('foo_bar')).toEqual('Foo bar');
    });

    it("strips of the id suffix", function() {
      expect(this.note.humanAttributeName('foo_bar_id')).toEqual('Foo bar');
    });
  });
});
