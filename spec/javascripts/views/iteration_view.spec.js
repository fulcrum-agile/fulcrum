describe('IterationView', function() {

  beforeEach(function() {
    var Iteration = Backbone.Model.extend({
      name: 'iteration', points: function() { return 999; },
      acceptedPoints: function() { return 555; },
      startDate: function() { return new Date('2011/09/26'); }
    });
    this.iteration = new Iteration({'number': 1});
    this.view = new IterationView({model: this.iteration});
  });

  it("should have a div as its top level element", function() {
    expect(this.view.el.nodeName).toEqual('DIV');
  });

  it("should have a class of iteration", function() {
    expect($(this.view.el)).toHaveClass('iteration');
  });

  it("should have the iteration number and date", function() {
    var el = $(this.view.render().el);
    expect(el.contents().first()).toHaveText('1 - Mon Sep 26 2011');
  });

  it("should have the number of points", function() {
    var el = $(this.view.render().el);
    expect($('span.points', el)).toHaveText('999');
  });

  it("should show 0 points", function() {
    this.iteration.points = function() { return 0; };
    var el = $(this.view.render().el);
    expect($('span.points', el)).toHaveText('0');
  });

  describe("current iteration", function() {

    it("should have the number of accepted / total points", function() {
      this.iteration.set({'column': '#in_progress'});
      var el = $(this.view.render().el);
      expect($('span.points', el)).toHaveText('555/999');
    });

  });
});
