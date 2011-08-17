describe('NoteCollection collection', function() {


  beforeEach(function() {
    this.story = new Story({id: 1, title: "Story", position: '10.0'});
		this.note1 = new Note({id: 1, text: "Note text 1"})
		this.note2 = new Note({id: 1, text: "Note text 2"})
		this.note3 = new Note({id: 1, text: "Note text 3"})
		
    this.story.notes.add([this.note1, this.note2, this.note1]);
  });

});