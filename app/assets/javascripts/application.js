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
  $('.tag-tooltip').tooltip();
  return executeAttachinary();
});

function executeAttachinary() {
  var js_template = [
    "<ul class='attachinary_images_list'>",
    "<% if ( files.length == 0 ) { %>",
    "  <li>zero documents uploaded yet</li>",
    "<% } %>",
    "<% for(var i = 0; i < files.length; i++) { %>",
    "  <li>",
    "    <% if ( files[i] && files[i].resource_type == \"raw\" ) { %>",
    "      <div class=\"raw-file\">",
    "        Document: ",
    "        <a href=\"<%= $.cloudinary.url(files[i].public_id, { resource_type: 'raw' }) %>\" target=\"_blank\">",
    "           <%= files[i].public_id %>",
    "        </a>",
    "        <a href=\"#\" data-remove=\"<%= files[i].public_id %>\">Remove</a>",
    "      </div>",
    "    <% } else { %>",
    "      <a href=\"<%= $.cloudinary.url(files[i].public_id) %>\" target=\"_blank\">",
    "        <img src=\"<%= $.cloudinary.url(files[i].public_id, { \"version\": files[i].version, \"format\": 'jpg', \"crop\": 'fill', \"width\": 75, \"height\": 75 }) %>\"",
    "        alt=\"\" width=\"75\" height=\"75\" />",
    "      </a>",
    "      <a href=\"#\" data-remove=\"<%= files[i].public_id %>\">Remove</a>",
    "    <% } %>",
    "  </li>",
    "<% } %>",
    "</ul>"
    ].join('\n');
  return $('.attachinary-input').attachinary({
    template: js_template
  });
}
