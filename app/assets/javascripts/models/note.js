if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.Note = Backbone.Model.extend({

  name: 'note',

  i18nScope: 'activerecord.attributes.note',

  user: function() {
    var userId = this.get('user_id');
    return this.collection.story.collection.project.users.get(userId);
  },

  userName: function() {
    var user = this.user();
    return user ? user.get('name') : 'Author unknown';
  }

});

_.defaults(Fulcrum.Note.prototype, Fulcrum.SharedModelMethods);
