namespace :fulcrum do
  desc "Set up database yaml."
  task :setup do
    example_database_config = Rails.root.join('config',"database.yml.example")
    database_config = Rails.root.join('config',"database.yml")

    unless File.exists?(database_config)
      cp example_database_config, database_config
    else
      puts "#{database_config} already exists!"
    end
  end
  
  desc "Import a pivotal tracker project."
  task :import => :environment do
    require 'pivotal-tracker'
    project = Project.find(ENV['PROJECT_ID'])
    PivotalTracker::Client.token = ENV['PIVOTAL_TOKEN']
    pivotal_project = PivotalTracker::Project.find(ENV['PIVOTAL_ID'])
    project.suppress_notifications = true
    project.stories.destroy_all
    pivotal_project.stories.all.each do |pivotal_story|
      begin
        puts "Importing #{pivotal_story.name}..."
        story = project.stories.create(:title => pivotal_story.name,
                                       :description => pivotal_story.description,
                                       :estimate => pivotal_story.estimate,
                                       :story_type => pivotal_story.story_type,
                                       :state => pivotal_story.current_state,
                                       :accepted_at => pivotal_story.accepted_at,
                                       :created_at => pivotal_story.created_at,
                                       :labels => pivotal_story.labels,
                                       :owned_by => project.users.find_by_name(pivotal_story.owned_by))
        pivotal_story.notes.all.each do |pivotal_note|
          story.notes.create(:note => pivotal_note.text,
                             :user => pivotal_note.author,
                             :created_at => pivotal_note.noted_at)
        end
      rescue
        puts "WARNING UNABLE TO IMPORT:  #{pivotal_story.name}..."
      end
    end
  end
end
