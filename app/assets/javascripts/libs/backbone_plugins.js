require('vendor/backbone.rails');

Backbone.View = (function(View) {
  return View.extend({
    constructor: function(options) {
      this.options = options || {};
      View.apply(this, arguments);
    },
    make: function(tagName, attributes, content) {
      var el = document.createElement(tagName);
      if (attributes) $(el).attr(attributes);
      if (content) $(el).html(content);
      return el;
    }
  });
})(Backbone.View);