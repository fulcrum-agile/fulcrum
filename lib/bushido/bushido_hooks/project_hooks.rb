class ProjectHooks < Bushido::EventObserver
  def project_created
    puts params.inspect
    puts "prarm"
    data = params['data']

    project   = Project.find_by_ido_id(data['ido_id'])
    project ||= Project.new

    # Just in case
    project.ido_id            ||= data['ido_id']
    project.name                = data['name']
    project.point_scale         = 'linear' || data['point_scale'] # TODO: Put in a reverse lookup
    project.iteration_start_day = data['iteration_start_day']
    project.iteration_length    = data['iteration_length']

    project.save!
  end

  def project_imported
    project_created
  end
end
