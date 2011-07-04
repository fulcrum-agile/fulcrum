describe('UserCollection collection', function() {

  beforeEach(function() {
    var User = Backbone.Model.extend({
      name: 'user',
    });

    this.users = new UserCollection();
  });


});
