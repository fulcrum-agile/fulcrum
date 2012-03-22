describe('NoteView', function() {

  beforeEach(function() {
    this.view = new NoteView();
  });

  it("has div as the tag name", function() {
    expect(this.view.el.nodeName).toEqual('DIV');
  });

  it("has the note class", function() {
    expect($(this.view.el)).toHaveClass('note');
  });

});
