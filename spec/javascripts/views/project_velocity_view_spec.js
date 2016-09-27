var rewire = require('rewire');
var ProjectVelocityView = rewire('views/project_velocity_view');

describe('ProjectVelocityView', function() {

  beforeEach(function() {
    this.model = {on: sinon.stub()};
    var overrideView = this.overrideView = {};
    function ProjectVelocityOverrideView() {
      return overrideView;
    }

    ProjectVelocityOverrideView.prototype.template = sinon.stub();

    this.revertRewire = ProjectVelocityView.__set__({
      ProjectVelocityOverrideView: ProjectVelocityOverrideView
    });

    this.subject = new ProjectVelocityView({model: this.model});
  });

  afterEach(function() {
    this.revertRewire();
  });

  it("should have a top level element", function() {
    expect(this.subject.el.nodeName).toEqual('DIV');
  });

  describe("initialize", function() {

    it("creates the override view", function() {
      expect(this.subject.override_view).toEqual(this.overrideView);
    });

    it("binds setFakeClass to change:userVelocity on the model", function() {
      expect(this.model.on).toHaveBeenCalledWith(
        "change:userVelocity", this.subject.setFakeClass
      );
    });

    it("binds render to rebuilt-iterations on the model", function() {
      expect(this.model.on).toHaveBeenCalledWith(
        "rebuilt-iterations", this.subject.render
      );
    });

  });

  describe("render", function() {

    beforeEach(function() {
      this.subject.$el.html = sinon.stub();
      this.subject.setFakeClass = sinon.stub();
      this.template = {};
      this.subject.template = sinon.stub().withArgs({project: this.model}).returns(this.template);
    });

    it("renders the template", function() {
      this.subject.render();
      expect(this.subject.$el.html).toHaveBeenCalledWith(this.template);
    });

    it("calls setFakeClass()", function() {
      this.subject.render();
      expect(this.subject.setFakeClass).toHaveBeenCalledWith(this.model);
    });

    it("returns itself", function() {
      expect(this.subject.render()).toBe(this.subject);
    });

  });

  describe("editVelocityOverride", function() {

    beforeEach(function() {
      this.el = {};
      this.subject.override_view.render = sinon.stub();
      this.subject.override_view.render.returns({el: this.el});
      this.subject.$el.append = sinon.stub();
    });

    it("appends the override view to its $el", function() {
      this.subject.editVelocityOverride();
      expect(this.subject.$el.append).toHaveBeenCalled(this.el);
    });

  });

  describe("setFakeClass", function() {

    beforeEach(function() {
      this.model.velocityIsFake = sinon.stub();
    });

    describe("when velocity is fake", function() {

      beforeEach(function() {
        this.model.velocityIsFake.returns(true);
      });

      it("adds the fake class to $el", function() {
        this.subject.setFakeClass(this.model);
        expect(this.subject.$el).toHaveClass('fake');
      });

    });

    describe("when velocity is not fake", function() {

      beforeEach(function() {
        this.model.velocityIsFake.returns(false);
      });

      it("adds the fake class to $el", function() {
        this.subject.setFakeClass(this.model);
        expect(this.subject.$el).not.toHaveClass('fake');
      });

    });
  });
});
