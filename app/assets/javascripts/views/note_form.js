if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.NoteForm = Fulcrum.FormView.extend({

  tagName: 'div',

  className: 'note_form',

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
    this.disableForm();

    var view = this;
    this.model.save(null, {
      success: function(model, response) {
        //view.model.set({editing: false});
      },
      error: function(model, response) {
        var json = $.parseJSON(response.responseText);
        view.enableForm();
        model.set({errors: json.note.errors});
        window.projectView.notice({
          title: I18n.t("save error", {defaultValue: "Save error"}),
          text: model.errorMessages()
        });
      }
    });
  },

  render: function() {
    var view = this;

    div = this.make('div');
    $(div).append(this.label("note"));
    $(div).append('<br/>');
    $(div).append(this.textArea("note"));

    var submit = this.make('input', {id: 'note_submit', type: 'button', value: 'Add note'});
    $(div).append(submit);
    this.$el.html(div);

    return this;
  },

  // Makes the note for uneditable during save
  disableForm: function() {
    this.$('input,textarea').attr('disabled', 'disabled');
    this.$('input[type="button"]').addClass('saving');
  },

  // Re-enables the note form once save is complete
  enableForm: function() {
    this.$('input,textarea').removeAttr('disabled');
    this.$('input[type="button"]').removeClass('saving');
  }
});
