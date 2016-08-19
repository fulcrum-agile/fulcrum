var SharedModelMethods = require('mixins/shared_model_methods');

var Task = module.exports = Backbone.Model.extend({

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

_.defaults(Task.prototype, SharedModelMethods);
