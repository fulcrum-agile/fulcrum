require 'csv'
if CSV.const_defined? :Reader
  require 'fastercsv'
  Object.send(:remove_const, :CSV)
  CSV = FasterCSV
  # CSV is now FasterCSV in ruby 1.9
end

project_id = 1

project = Project.find(project_id)
user = User.first

project.stories.destroy_all

csv = CSV.parse(STDIN.read, :headers => true)
csv.each do |row|
  row = row.to_hash
  project.stories.create!(:state => row["Current State"], :title => row["Story"],
                          :story_type => row["Story Type"], :requested_by => user,
                         :estimate => row["Estimate"])
end
