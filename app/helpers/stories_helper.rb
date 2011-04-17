module StoriesHelper
  def state_transition_button(story, state)
    path = send("#{state}_project_story_path", story.project, story)
    button_to(state, path, :method => :put, :class => state)
  end
end
