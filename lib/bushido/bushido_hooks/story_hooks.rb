class ProjectStoryHooks < Bushido::EventObserver
  def project_task_created
    data = params['data']

    story   = Story.find_by_ido_id(data['ido_id'])
    story ||= Story.new

    # Just in case
    story.ido_id        ||= data['ido_id']
    story.title           = data['title']
    story.description     = data['description']
    story.estimate        = data['estimate']
    story.story_type      = data['task_type']
    story.state           = data['state']
    story.accepted_at     = data['accepted_at']
    story.requested_by_id = User.find_by_ido_id(data['requested_by_id'])
    story.owned_by_id     = User.find_by_ido_id(data['owned_by_id'])
    story.project         = Project.find_by_ido_id(data['project_id'])
    story.labels          = data['labels']

    story.save
  end

  def project_task_imported
    project_task_created
  end
end
