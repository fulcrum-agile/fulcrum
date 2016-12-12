module.exports = {

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
    return (!_.isUndefined(this.get('errors')));
  },

  errorsOn: function(field) {
    if (!this.hasErrors()) {
      return false;
    }
    return (!_.isUndefined(this.get('errors')[field]));
  }
};
