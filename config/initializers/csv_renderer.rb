# Currently only used for rendering collections of stories, so make an
# assumption that that is what we get passed.
ActionController::Renderers.add :csv do |stories, options|

  filename = options[:filename] || 'export.csv'
  
  csv_string = CSV.generate do |csv|
    csv << Story.csv_headers
    stories.each do |story|
      csv << story.to_csv
    end
  end

  send_data csv_string, :type => Mime::CSV, :filename => filename

end
