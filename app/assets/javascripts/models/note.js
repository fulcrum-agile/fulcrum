if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.Note = Backbone.Model.extend({

  name: 'note',

  i18nScope: 'activerecord.attributes.note',

  readonly: false,

  sync: function(method, model, options) {
    if( model.readonly ) {
      return true;
    }
    Backbone.sync(method, model, options);
  }

});

_.defaults(Fulcrum.Note.prototype, Fulcrum.SharedModelMethods);
