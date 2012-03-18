class ProjectNoteHooks < Bushido::EventObserver
  def project_task_note_created
    data = params['data']

    note   = Note.find_by_ido_id(data['ido_id'])
    note ||= Note.new

    # Just in case
    note.ido_id ||= data['ido_id']
    note.note     = data['note']
    note.user     = User.find_by_ido_id( data['author_id'] )
    note.story    = Story.find_by_ido_id( data['story_id'] )
    
    note.save!
  end

  def project_task_note_imported
    project_task_note_created
  end
end
