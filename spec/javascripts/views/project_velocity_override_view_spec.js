describe('Fulcrum.ProjectVelocityOverrideView', function() {

  beforeEach(function() {
    this.project = {};
    this.subject = new Fulcrum.ProjectVelocityOverrideView({model: this.project});
  });

  describe("changeVelocity", function() {

    beforeEach(function() {
      sinon.stub(this.subject, 'requestedVelocityValue').returns(42);
      this.project.velocity = sinon.stub();
      this.subject.$el.remove = sinon.stub();
    });

    it("calls velocity() on the model", function() {
      this.subject.changeVelocity();
      expect(this.project.velocity).toHaveBeenCalledWith(42);
    });

    it("removes the $el", function() {
      this.subject.changeVelocity();
      expect(this.subject.$el.remove).toHaveBeenCalled();
    });

    it("returns false", function() {
      expect(this.subject.changeVelocity()).toEqual(false);
    });

  });

  describe("revertVelocity", function() {

    beforeEach(function() {
      this.project.revertVelocity = sinon.stub();
      this.subject.$el.remove = sinon.stub();
    });

    it("calls revertVelocity() on the model", function() {
      this.subject.revertVelocity();
      expect(this.project.revertVelocity).toHaveBeenCalled();
    });

    it("removes the $el", function() {
      this.subject.revertVelocity();
      expect(this.subject.$el.remove).toHaveBeenCalled();
    });

    it("returns false", function() {
      expect(this.subject.revertVelocity()).toEqual(false);
    });

  });

  describe("requestedVelocityValue", function() {

    beforeEach(function() {
      this.subject.$el.append('<input name="override" value="42">');
    });

    it("returns the right value", function() {
      expect(this.subject.requestedVelocityValue()).toEqual(42);
    });

  });
});
