describe('Fulcrum.FormView', function() {

  beforeEach(function() {
    Fulcrum.FormView.prototype.template = sinon.stub();
    this.view = new Fulcrum.FormView();
  });

  it("should have a form as its top level element", function() {
    expect(this.view.el.nodeName).toEqual('FORM');
  });

  describe("mergeAttrs", function() {
    it("merges an options hash with some defaults", function() {
      var opts = {foo: 'bar'};
      var defaults = {foo: 'baz', bar: 'baz'};
      expect(this.view.mergeAttrs(defaults, opts)).toEqual({foo: 'bar', bar: 'baz'});
      expect(defaults).toEqual({foo: 'bar', bar: 'baz'});
    });
  });

});
