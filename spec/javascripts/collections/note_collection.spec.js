describe('NoteCollection collection', function() {


  beforeEach(function() {
    var Story = Backbone.Model.extend({name: 'story'});
    this.story = new Story({url: '/foo'});
    this.story.url = function() { return '/foo'; };

    this.note_collection = new NoteCollection();
    this.note_collection.story = this.story;
  });

  describe("url", function() {

    it("should return the url", function() {
      expect(this.note_collection.url()).toEqual('/foo/notes');
    });

  });

});
