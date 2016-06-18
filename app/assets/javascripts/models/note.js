if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.Note = Backbone.Model.extend({

  name: 'note',

  fileAttribute: 'attachment',

  i18nScope: 'activerecord.attributes.note',

  user: function() {
    var userId = this.get('user_id');
    return this.collection.story.collection.project.users.get(userId);
  },

  attachmentUrl: function() {
    var attachment = this.get('attachment');

    if (attachment && attachment.url !== null) {
      return attachment.url
    }
    return "";
  },

  attachmentFileName: function() {
    var attachmentUrl = this.attachmentUrl();
    return _.last(attachmentUrl.split('/'));
  },

  userName: function() {
    var user = this.user();
    return user ? user.get('name') : 'Author unknown';
  }

});

_.defaults(Fulcrum.Note.prototype, Fulcrum.SharedModelMethods);
