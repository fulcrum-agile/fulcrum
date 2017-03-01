var ProjectView = require('views/project_view');

describe("ProjectView", function() {

  beforeEach(function() {
    this.model = {};
    this.model.on = sinon.stub();
    this.model.velocity = sinon.stub();
    this.model.velocityIsFake = sinon.stub();
    this.model.stories = {fetch: sinon.stub(), on: sinon.stub()};
    ProjectView.prototype.template = sinon.stub();
    this.view = new ProjectView({model: this.model});
  });

  describe("addColumnView", function() {

    beforeEach(function() {
      this.columnView = {};
    });

    it("adds the column view", function() {
      this.view.addColumnView('column_id', this.columnView);
      expect(this.view.columns.column_id).toBe(this.columnView);
    });

  });

});
