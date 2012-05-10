if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.SharedModelMethods = {

  // Returns the translated name of an attribute
  humanAttributeName: function(attribute) {
    attribute = attribute.replace(/_id$/, '');
    return I18n.t(attribute, {scope: this.i18nScope});
  },

  errorMessages: function() {
    return _.map(this.get('errors'), function(errors, field) {
      return _.map(errors, function(error) {
        return field + " " + error;
      }).join(', ');
    }).join(', ');
  },

  hasErrors: function() {
    return (typeof this.get('errors') != "undefined");
  },

  errorsOn: function(field) {
    if (!this.hasErrors()) {
      return false;
    }
    return (typeof this.get('errors')[field] != "undefined");
  }
};
