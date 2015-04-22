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
    "click .note-submit": "saveEdit"
	},

	saveEdit: function() {
    var fileObject = $(this.el).find('.note-attachment')[0].files[0];
    if (fileObject !== undefined) {
      this.model.set('attachment', fileObject);
    }
    this.disableForm();

    var view = this;
    this.model.save(null, {
      // therefore is not possible to send file object as a part of JSON,
      // it is better to always save backbone model info as a form object
      formData: true,
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
    $(div).append(this.textArea("note[note]"));

    var attachment = this.make('input', {id:'note_attachment', class:'note-attachment', name: 'attachment', type: 'file'})
    var submit = this.make('input', {id: 'note_submit', class:'note-submit', type: 'button', value: 'Add note'});
    $(div).append(attachment);
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
