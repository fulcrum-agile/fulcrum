describe('ProjectVelocityOverrideView', function() {

  beforeEach(function() {
    var Story = Backbone.Model.extend({
      name: 'story',
      fetch: function() {},
      position: function() {},
      labels: function() { return []; }
    });
    this.story = new Story({id: 456});

    this.project = new Project({
      id: 999, title: 'Test project', point_values: [0, 1, 2, 3],
      last_changeset_id: null, iteration_start_day: 1, iteration_length: 1
    });
    this.project.stories.add(this.story);

    this.view = new ProjectVelocityView({model: this.project});
    $(this.view.render().el).find("span").click();

    this.velocityOverrideView = new ProjectVelocityOverrideView({model: this.project});
  });

  it("should show the current project velocity", function() {
    var el = $(this.view.render().el).find("span");
    expect(el.text()).toEqual(this.project.velocity().toString());
  });

});

