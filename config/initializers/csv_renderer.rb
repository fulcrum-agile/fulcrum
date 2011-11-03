# Currently only used for rendering collections of stories, so make an
# assumption that that is what we get passed.
ActionController::Renderers.add :csv do |stories, options|

  filename = options[:filename] || 'export.csv'


  # Calculate the number of Notes headers that will be required, and append
  # this many "Note" headers to the CSV
  headers = Story.csv_headers
  story_with_most_notes = stories.max_by {|s| s.notes.count}

  if story_with_most_notes
    max_notes = story_with_most_notes.notes.length
    headers.concat(Array.new(max_notes, "Note"))
  end
  
  csv_string = CSV.generate do |csv|
    csv << Story.csv_headers
    stories.each do |story|
      csv << story.to_csv
    end
  end

  send_data csv_string, :type => Mime::CSV, :filename => filename

end
