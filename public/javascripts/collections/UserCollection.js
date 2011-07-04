var UserCollection = Backbone.Collection.extend({
  model: User,

  forSelect: function() {
    return this.map(function(user) {
      return [user.get('name'),user.id];
    });
  }
});
