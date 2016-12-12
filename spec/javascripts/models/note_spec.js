var Note = require('models/note');

describe("Note", function() {

  beforeEach(function() {
    this.note = new Note({});
  });

  describe("user", function() {

    beforeEach(function() {
      this.project = {users: {get: this.usersCollectionStub}};
      this.note.set({user_id: 999, user_name: 'John Doe'});
      this.note.collection = {story: {collection: {project: this.project}}};
    });

    it("returns the name of the user", function() {
      expect(this.note.get('user_name')).toEqual('John Doe');
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
