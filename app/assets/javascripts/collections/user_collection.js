if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.UserCollection = Backbone.Collection.extend({
  model: Fulcrum.User,

  forSelect: function() {
    return this.map(function(user) {
      return [user.get('name'),user.id];
    });
  }
});
