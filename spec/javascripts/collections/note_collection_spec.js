describe('Fulcrum.NoteCollection', function() {

  beforeEach(function() {
    var Story = Backbone.Model.extend({name: 'story'});
    this.story = new Story({url: '/foo'});
    this.story.url = function() { return '/foo'; };

    this.note_collection = new Fulcrum.NoteCollection();
    this.note_collection.story = this.story;
  });

  describe("url", function() {

    it("should return the url", function() {
      expect(this.note_collection.url()).toEqual('/foo/notes');
    });

  });

  it("should return only saved notes", function() {
    this.note_collection.add({id: 1, note: "Saved note"});
    this.note_collection.add({note: "Unsaved note"});
    expect(this.note_collection.length).toEqual(2);
    expect(this.note_collection.saved().length).toEqual(1);
  });

});
