//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.gritter
//= require jquery.scrollTo
//= require jquery.atwho
//= require clipboard
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
//= require Chart.bundle
//= require chartkick
//= require_tree .

$(function() {
  $('.tag-tooltip').tooltip();

  $(".menu-toggle").click(function(e) {
      e.preventDefault();
      $("#sidebar-wrapper").toggle();
  });

  executeAttachinary();
});

function executeAttachinary() {
  $('.attachinary-input').attachinary({ template: $('#attachinary_template').html() });
}

