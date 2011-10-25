var NoteForm = FormView.extend({

  tagName: 'div',

  initialize: function() {
	  // Supply the model with a reference to it's own view object, so it can
    // remove itself from the page when destroy() gets called.
    this.model.view = this;

    if (this.model.id) {
      this.id = this.el.id = this.model.id;
    }
	},

	events: {
    "click input": "saveEdit"
	},
	
	saveEdit: function() {
    this.model.set(this.changed_attributes);
    //this.disableForm();

    var view = this;
    this.model.save(null, {
      success: function(model, response) {
        view.model.set({editing: false});
        //view.enableForm();
      },
      error: function(model, response) {
        var json = $.parseJSON(response.responseText);
        model.set({editing: true, errors: json.note.errors});
        App.notice({title: "Save error", text: model.errorMessages()});
        //view.enableForm();
      }
    });
  },

  render: function() {
    var view = this;

    div = this.make('div');
    $(div).append(this.label("note", "Note"));
    $(div).append('<br/>');
    $(div).append(this.textArea("note"));

    var submit = this.make('input', {id: 'note_submit', type: 'button', value: 'Add note'});
    $(div).append(submit);
    $(this.el).html(div);

    return this;
  }
});
