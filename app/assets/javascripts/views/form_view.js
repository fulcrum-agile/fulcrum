if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.FormView = Backbone.View.extend({
  tagName: 'form',

  label: function(elem_id, value) {
    value = value || this.model.humanAttributeName(elem_id);
    return this.make('label', {'for': elem_id}, value);
  },

  textField: function(name, extra_opts) {
    var defaults = {type: "text", name: name, value: this.model.get(name)}
    this.mergeAttrs(defaults, extra_opts);
    var el = this.make('input', defaults);
    this.bindElementToAttribute(el, name, "keyup");
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

  select: function(name, select_options, options) {
    var select = this.make('select', {name: name});
    var view = this;
    var model = this.model;

    if (typeof options == 'undefined') {
      options = {};
    }

    if (options.blank) {
      $(select).append(this.make('option', {value: ''}, options.blank));
    }

    _.each(select_options, function(option) {
      if (option instanceof Array) {
        option_name = option[0];
        option_value = option[1];
      } else {
        option_name = option_value = option + '';
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

  bindElementToAttribute: function(el, name, eventType) {
    var that = this;
    eventType = typeof(eventType) != 'undefined' ? eventType : "change";
    $(el).bind(eventType, function() {
      var obj = {};
      obj[name] = $(el).val();
      that.model.set(obj, {silent: true});
      return true;
    });
  },

  mergeAttrs: function(defaults, opts) {
    return jQuery.extend(defaults, opts);
  }
});
