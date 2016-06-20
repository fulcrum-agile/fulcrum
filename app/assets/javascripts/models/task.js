if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.Task = Backbone.Model.extend({

  name: 'task',

  i18nScope: 'activerecord.attributes.task',

  defaults: {
    done: false
  }

});

_.defaults(Fulcrum.Task.prototype, Fulcrum.SharedModelMethods);
