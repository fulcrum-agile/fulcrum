var FormView = Backbone.View.extend({
  tagName: 'form',

  label: function(name) {
    return this.make('label', {for: name}, name);
  },

  textField: function(name) {
    var el = this.make('input', {type: "text", name: name, value: this.model.get(name)});
    this.bindElementToAttribute(el, name);
    return el;
  }, 

  hiddenField: function(name) {
    var el = this.make('input', {type: "hidden", name: name, value: this.model.get(name)});
    this.bindElementToAttribute(el, name);
    return el;
  }, 

  textArea: function(name) {
    var el = this.make('textarea', {name: name, value: this.model.get(name)});
    this.bindElementToAttribute(el, name);
    return el;
  },

  select: function(name, options) {
    var select = this.make('select', {name: name});
    var view = this;
    var model = this.model;
    _.each(options, function(option) {
      if (option instanceof Array) {
        option_name = option[0];
        option_value = option[1];
      } else {
        option_name = option_value = option;
      }
      var attr = {value: option_value};
      if (model.get(name) == option_value) {
        attr.selected = true;
      }
      $(select).append(view.make('option', attr, option_name));
    });
    this.bindElementToAttribute(select, name);
    return select;
  },

  checkBox: function(name) {
    var attr = {type: "checkbox", name: name, value: 1};
    if (this.model.get(name)) {
      attr.checked = "checked";
    }
    var el = this.make('input', attr);
    this.bindElementToAttribute(el, name);
    return el;
  },

  submit: function() {
    var el = this.make('input', {id: "submit", type: "button", value: "Save"});
    return el;
  },

  destroy: function() {
    var el = this.make('input', {id: "destroy", type: "button", value: "Delete"});
    return el;
  },

  cancel: function() {
    var el = this.make('input', {id: "cancel", type: "button", value: "Cancel"});
    return el;
  },

  bindElementToAttribute: function(el, name) {
    var model = this.model;
    $(el).bind("change", function() {
      var attributes = {};
      attributes[name] = $(el).val();
      model.set(attributes);
    });
  },
});
