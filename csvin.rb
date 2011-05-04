require 'fastercsv'

project_id = 1

project = Project.find(project_id)
user = User.first

project.stories.destroy_all

csv = FasterCSV.parse(STDIN.read, :headers => true)
csv.each do |row|
  row = row.to_hash
  project.stories.create!(:state => row["Current State"], :title => row["Story"],
                          :story_type => row["Story Type"], :requested_by => user,
                         :estimate => row["Estimate"])
end
