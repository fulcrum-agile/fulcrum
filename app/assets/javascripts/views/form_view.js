module.exports = Backbone.View.extend({
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
    var el = this.make('textarea', {name: name, class: 'form-control' }, this.model.get(name));
    $(el).attr('style', 'height:100px;overflow-y:hidden;');
    $(el).on('input', function () {
      this.style.height = 'auto';
      this.style.height = (this.scrollHeight) + 'px';
    });

    this.bindElementToAttribute(el, name);
    return el;
  },

  fileField: function(name, progress_element_id, finished_element_id, attachinary_container_id) {
    var field_name = name + ( ATTACHINARY_OPTIONS['html']['multiple'] ? '[]' : '' );
    var files = this.model.get('documents');
    if(files) {
      files = files.map(function(d) { return d.file });
    }
    var options = $.extend(ATTACHINARY_OPTIONS['attachinary'], {
      files_container_selector: '#' + attachinary_container_id, 'files': files });
    var el = this.make('input', {name: field_name, type: "file", class: 'attachinary-input',
                       'data-attachinary': JSON.stringify(options),
                       'data-form-data': JSON.stringify(ATTACHINARY_OPTIONS['html']['data']['form_data']),
                       'data-url': ATTACHINARY_OPTIONS['html']['data']['url'],
                       'multiple': ( ATTACHINARY_OPTIONS['html']['multiple'] ? 'multiple' : '' ),
                       });

    $(el).bind('fileuploadprogressall', (function(_this, _progress_element_id, _finished_element_id) {
      return function(e, data) {
        var el_progress = $('#' + _progress_element_id);
        if ( el_progress.is(":hidden") )
          el_progress.show();

        var progress = parseInt(data.loaded / data.total * 100, 10);
        el_progress.css('width', progress + "%");

        if (progress == 100) {
          el_progress.css('width', "1px");
          el_progress.hide();

          $('#' + _finished_element_id).show();
        }
      };
    })(this, progress_element_id, finished_element_id));
    this.bindElementToAttribute(el, name);
    return el;
  },

  select: function(name, select_options, options) {
    if (typeof options == 'undefined') {
      options = {};
    }

    options = _.defaults(options, { attrs: { class: [] } });

    options.attrs.class = 'form-control input-sm ' +options.attrs.class.join(' ');

    var select = this.make('select', _.extend({name: name}, options.attrs));

    var view = this;
    var model = this.model;


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
    var el = this.make('input', {class: "submit", type: "button", value: I18n.t('save')});
    return el;
  },

  destroy: function() {
    var el = this.make('input', {class: "destroy", type: "button", value: I18n.t('delete')});
    return el;
  },

  cancel: function() {
    var el = this.make('input', {class: "cancel", type: "button", value: I18n.t('cancel')});
    return el;
  },

  bindElementToAttribute: function(el, name, eventType) {
    var that = this;
    eventType = typeof(eventType) != 'undefined' ? eventType : "change";
    $(el).on(eventType, function() {
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
