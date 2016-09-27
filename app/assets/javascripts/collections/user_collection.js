var User = require('models/user');

module.exports = Backbone.Collection.extend({
  model: User,

  comparator: function(user) {
    return user.get('name');
  },

  forSelect: function() {
    return this.sort().map(function(user) {
      return [user.get('name'),user.id];
    });
  }
});
