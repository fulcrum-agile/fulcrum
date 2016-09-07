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
  sidebarAction();
  executeAttachinary();
  changeLocaleEvent();
});

function executeAttachinary() {
  $('.attachinary-input').attachinary({ template: $('#attachinary_template').html() });
}

function sidebarAction() {
  $(".menu-toggle").click(function(e) {
    e.preventDefault();
    if($("#sidebar-wrapper").is(':hidden')) {
      $('.click-overlay').on('click', function() {
        hideSidebar();
      });
      showSidebar();
    } else {
      hideSidebar();
    }
  });
}

function showSidebar() {
  $("#sidebar-wrapper").show();
  $('.click-overlay').show();
}

function hideSidebar() {
  $('.click-overlay').off('click');
  $("#sidebar-wrapper").hide();
  $('.click-overlay').hide();
}

function changeLocaleEvent() {
  $('.locale-change').on('change', function(e) {
    e.preventDefault();
    $(this).parent('form').submit();
  });
}
