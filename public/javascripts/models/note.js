var Note = Backbone.Model.extend({

  name: 'note',

  user: function() {
    var userId = this.get('user_id');
    return this.collection.story.collection.project.users.get(userId);
  }

});
