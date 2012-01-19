describe('ProjectVelocityOverrideView', function() {

  beforeEach(function() {
    this.project = new Project({
      id: 999, title: 'Test project', point_values: [0, 1, 2, 3],
      last_changeset_id: null, iteration_start_day: 1, iteration_length: 1
    });

    this.velocityOverrideView = new ProjectVelocityOverrideView({model: this.project});
  });

  it("should show the current project velocity in the input form", function() {
    this.project.velocity(30);
    inputFieldValue = $(this.velocityOverrideView.render().el).find("input[name=override]").attr("value");
    expect(inputFieldValue).toBe('30');
  });
});
