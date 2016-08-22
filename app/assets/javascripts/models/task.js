if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.Task = Backbone.Model.extend({

  name: 'task',

  i18nScope: 'activerecord.attributes.task',

  defaults: {
    done: false
  },

  isReadonly: false,

  sync: function(method, model, options) {
    if( model.isReadonly ) {
      return true;
    }
    Backbone.sync(method, model, options);
  }

});

_.defaults(Fulcrum.Task.prototype, Fulcrum.SharedModelMethods);
