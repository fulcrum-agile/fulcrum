var FormView = require('views/form_view');

describe('FormView', function() {

  beforeEach(function() {
    FormView.prototype.template = sinon.stub();
    this.view = new FormView();
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
