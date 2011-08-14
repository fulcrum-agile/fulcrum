var Note = Backbone.Model.extend({
  name: 'note',

  initialize: function(args) {

    this.maybeUnwrap(args);
  }
});