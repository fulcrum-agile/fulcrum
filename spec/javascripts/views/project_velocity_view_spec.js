describe('Fulcrum.ProjectVelocityView', function() {

  beforeEach(function() {
    var Story = Backbone.Model.extend({
      name: 'story',
      fetch: function() {},
      position: function() {},
      labels: function() { return []; }
    });
    this.story = new Story({id: 456});

    this.project = new Fulcrum.Project({
      id: 999, title: 'Test project', point_values: [0, 1, 2, 3],
      last_changeset_id: null, iteration_start_day: 1, iteration_length: 1
    });
    this.project.stories.add(this.story);

    this.view = new Fulcrum.ProjectVelocityView({model: this.project});
  });

  it("should have a top level element", function() {
    expect(this.view.el.nodeName).toEqual('DIV');
  });

  // FIXME - Test too tightly coupled to view rendering
  xdescribe("when rendered", function() {
    beforeEach(function() {
      $(this.view.render().el);
    });

    it("should contain text with the default velocity", function() {
      expect(this.view.$el.find("span").text()).toEqual('10');
    });
  });

  xdescribe("when velocity is overridden", function() {
    beforeEach(function() {
      this.project.velocity(999);
    });

    describe("when rendered", function() {
      beforeEach(function() {
        this.view.render();
      });

      it("should contain text with the overridden velocity", function() {
        expect(this.view.$el.find("span").text()).toEqual('999');
      });

    });
  });

  xdescribe("when velocity is reverted", function() {
    beforeEach(function() {
      this.project.revertVelocity();
    });

    describe("when rendered", function() {
      beforeEach(function() {
        $(this.view.render().el);
      });

      it("should contain text with the overridden velocity", function() {
        expect(parseInt(this.view.$el.find("span").text(), 10)).toEqual(this.project.get('default_velocity'));
      });
    });
  });

  xdescribe("setFakeClass", function() {
    describe("when velocity is not overridden", function() {
      beforeEach(function() {
        this.project.velocityIsFake = function() { return false; };
      });

      it("doesn't have the fake class", function() {
        expect($(this.view.render().el)).not.toHaveClass('fake');
      });
    });

    describe("when velocity is overridden", function() {
      beforeEach(function() {
        this.project.velocityIsFake = function() { return true; };
      });

      it("has the fake class", function() {
        expect($(this.view.render().el)).toHaveClass('fake');
      });
    });
  });
});
