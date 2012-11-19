describe('Fulcrum.NoteView', function() {

  beforeEach(function() {
    var Note = Backbone.Model.extend({name: 'note', url: '/foo'});
    this.note = new Note({});
    this.view = new Fulcrum.NoteView({model: this.note});
  });

  it("has div as the tag name", function() {
    expect(this.view.el.nodeName).toEqual('DIV');
  });

  it("has the note class", function() {
    expect($(this.view.el)).toHaveClass('note');
  });

  describe("deleteNote", function() {
    it("should call destroy on the model", function() {
      var deleteSpy = sinon.spy(this.view.model, 'destroy');
      this.view.deleteNote();
      expect(deleteSpy).toHaveBeenCalled();
    });

    it("should remove element", function() {
      var removeSpy = sinon.spy(this.view.$el, 'remove');
      this.view.deleteNote();
      expect(removeSpy).toHaveBeenCalled();
    });
  });
});
