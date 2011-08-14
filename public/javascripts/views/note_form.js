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
    "click #note-submit": "save"
	},
	
	save: function() {
		console.debug(this.model);
		/*
    this.model.set(this.changed_attributes);
    this.disableForm();

    var that = this;
    this.model.save(null, {
      success: function(model, response) {
        that.model.set({editing: false});
        that.enableForm();
      },
      error: function(model, response) {
        var json = $.parseJSON(response.responseText);
        model.set({editing: true, errors: json.note.errors});
        App.notice({title: "Save error", text: model.errorMessages()});
        that.enableForm();
      }
    });
*/
  },

  render: function() {
    $(this.el).empty();

    div = this.make('div');
    $(div).append(this.label("text", "Text"));
    $(div).append('<br/>');
    $(div).append(this.textArea("text"));
    //$(this.el).append(div);

    //div = this.make('div');
    $(div).append($(this.submit()).attr('id', 'note-submit'));
    $(this.el).append(div);

		console.debug(this.el);

    return this;
  }
});