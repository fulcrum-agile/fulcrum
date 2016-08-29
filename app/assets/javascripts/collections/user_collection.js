if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.UserCollection = Backbone.Collection.extend({
  model: Fulcrum.User,

  comparator: function(user) {
    return user.get('name');
  },

  forSelect: function() {
    return this.sort().map(function(user) {
      return [user.get('name'),user.id];
    });
  }
});
