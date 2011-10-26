var Note = Backbone.Model.extend({

  name: 'note',

  user: function() {
    var userId = this.get('user_id');
    return this.collection.story.collection.project.users.get(userId);
  },

  userName: function() {
    var user = this.user();
    return user ? user.get('name') : 'Author unknown';
  },

  // FIXME - DRY, repeated in Story model
  hasErrors: function() {
    return (typeof this.get('errors') != "undefined");
  },

  // FIXME - DRY, repeated in Story model
  errorsOn: function(field) {
    if (!this.hasErrors()) {
      return false;
    }
    return (typeof this.get('errors')[field] != "undefined");
  },

  // FIXME - DRY, repeated in Story model
  errorMessages: function() {
    return _.map(this.get('errors'), function(errors, field) {
      return _.map(errors, function(error) {
        return field + " " + error;
      }).join(', ');
    }).join(', ');
  }
});
