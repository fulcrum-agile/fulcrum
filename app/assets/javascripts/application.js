//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.gritter
//= require jquery.scrollTo
//= require date.format
//= require underscore
//= require backbone
//= require backbone.rails
//= require Markdown.Converter
//= require backbone.compat
//= require_tree ./templates
//= require_tree ./mixins
//= require_tree ./models
//= require_tree ./collections
//= require_tree ./views
//= require fulcrum
//= require bootstrap-sprockets
//= require tag-it
//= require i18n
//= require i18n/translations
//= require locales
//= require jquery.ui.widget
//= require jquery.iframe-transport
//= require jquery.fileupload
//= require cloudinary/jquery.cloudinary
//= require attachinary
//= require_tree .

$(function() {
  return $('.attachinary-input').attachinary({
    template: "<ul>\n  <% for(var i=0; i<files.length; i++){ %>\n    <li>\n      <% if(files[i].resource_type == \"raw\") { %>\n        <div class=\"raw-file\"><%= files[i].original_filename %></div>\n      <% } else { %>\n        <img\n          src=\"<%= $.cloudinary.url(files[i].public_id, { \"version\": files[i].version, \"format\": 'jpg', \"crop\": 'fill', \"width\": 75, \"height\": 75 }) %>\"\n          alt=\"\" width=\"75\" height=\"75\" />\n      <% } %>\n      <a href=\"#\" data-remove=\"<%= files[i].public_id %>\">Remove</a>\n    </li>\n  <% } %>\n</ul>"
  });
});
