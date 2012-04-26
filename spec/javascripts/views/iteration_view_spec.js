describe('Fulcrum.IterationView', function() {

  beforeEach(function() {
    var Iteration = Backbone.Model.extend({
      name: 'iteration', points: function() { return 999; },
      acceptedPoints: function() { return 555; },
      startDate: function() { return new Date('2011/09/26'); }
    });
    this.iteration = new Iteration({'number': 1});
    this.view = new Fulcrum.IterationView({model: this.iteration});
  });

  it("should have a div as its top level element", function() {
    expect(this.view.el.nodeName).toEqual('DIV');
  });

  it("should have a class of iteration", function() {
    expect($(this.view.el)).toHaveClass('iteration');
  });

  describe("render", function() {

    beforeEach(function() {
      this.view.template.returns('<p>foo</p>');
    });

    it("calls the template with the iteration and view as arguments", function() {
      this.view.render();
      expect(this.view.template).toHaveBeenCalledWith({
        iteration: this.iteration, view: this.view
      });
    });

    it("renders the output of the template into the el", function() {
      this.view.render();
      expect(this.view.$el.html()).toEqual('<p>foo</p>');
    });

  });

  describe("points", function() {

    it("displays points when column is not #in_progress", function() {
      this.iteration.set({'column': '#backlog'});
      expect(this.view.points()).toEqual(999);
    });

    it("displays accepted / total when column is #in_progress", function() {
      this.iteration.set({'column': '#in_progress'});
      expect(this.view.points()).toEqual('555/999');
    });

  });
});
