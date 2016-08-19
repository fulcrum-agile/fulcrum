if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.Note = Backbone.Model.extend({

  name: 'note',

  i18nScope: 'activerecord.attributes.note',

});

_.defaults(Fulcrum.Note.prototype, Fulcrum.SharedModelMethods);
