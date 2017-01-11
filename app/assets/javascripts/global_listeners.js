var executeAttachinary = require('libs/execute_attachinary');
var KeycutView = require('views/keycut_view');

var $navbar = $(".navbar");
var $navbarToggle = $('.toggle-navbar.more');
var $sidebarToggleIcon = $("#sidebar-toggle").children('.mi');
var $sidebarWrapper = $("#sidebar-wrapper");

$(function() {
  $('[data-toggle="tooltip"]').tooltip();

  $('[data-form-submit]').click(function(e) {
    e.preventDefault();
    $(this).closest('form').submit()
  });

  $('.toggle-navbar').click(function(e) {
    e.preventDefault();

    if($navbar.is(':hidden')) {
      showNavbar();
    } else {
      hideNavbar();
    }
  });

  $('#add_story').click(function() {
    window.projectView.newStory();

    // Show chilly bin if it's hidden
    $('.hide_chilly_bin.pressed').click();
    var newStoryElement = $('#chilly_bin div.story:last');
    $('#chilly_bin').scrollTo(newStoryElement, 100);
  });

  // keycut listener
  $('html').keypress(function(event){
      var code = event.which || event.keyCode;
      var keyChar = String.fromCharCode(code);
      switch (code) {
        case 63: // ? | Should only work without a focused element
          if (!$(':focus').length) {
            if ($('#keycut-help').length) {
              $('#keycut-help').fadeOut(function(){
                $('#keycut-help').remove();
              });
            } else {
              new KeycutView().render();
            };
          };
          break;
        case 66: // B | Should only work without a focused element
          if (!$(':focus').length) {
            $('a.hide_backlog').first().click();
          };
          break;
        case 67: // C | Should only work without a focused element
          if (!$(':focus').length) {
            $('a.hide_chilly_bin').first().click();
          };
          break;
        case 68: // D | Should only work without a focused element
          if (!$(':focus').length) {
            $('a.hide_done').first().click();
          };
          break;
        case 80: // P | Should only work without a focused element
          if (!$(':focus').length) {
            $('a.hide_in_progress').first().click();
          };
          break;

        case 97: // a | Should only work without a focused element
          if (!$(':focus').length && window.projectView) {
            window.projectView.newStory();
            $('.hide_chilly_bin.pressed').first().click();
            var newStoryElement = $('#chilly_bin div.story:last');
            $('#chilly_bin').scrollTo(newStoryElement, 100);
            return false;
          };
          break;
        case 19: // <cmd> + s
          $('.story.editing').find('.submit').click()
        default:
          // whatever
      };
    });

  $sidebarWrapper.mouseenter(_.debounce(function(){
    $sidebarWrapper.toggleClass('open');
  }, 500));

  $sidebarWrapper.mouseleave(function(){
    $sidebarWrapper.removeClass('open');
  });

  $("#sidebar-toggle").click(function(e) {
    e.preventDefault();

    if ($sidebarWrapper.hasClass('collapsed'))
      $sidebarToggleIcon.text('close');
    else
      $sidebarToggleIcon.text('menu');

    $sidebarWrapper.toggleClass('collapsed')
  });

  $('.tag-tooltip').tooltip();

  $('.locale-change').on('change', function(e) {
    e.preventDefault();
    $(this).parent('form').submit();
  });

  if ($('.change-team')) {
    if (_.isUndefined($('#user_team_slug').attr('readonly'))) {
      $('.change-team').css('display', 'none');
    } else {
      $('.change-team').on('click', function() {
        $('#user_team_slug').attr('readonly', false);
        $('#user_team_slug').val('');
        $('#user_team_slug').focus();
        $('.change-team').css('display', 'none');
      });
    }
  }

  executeAttachinary();
});

function showNavbar() {
  $navbar.show();
  $navbarToggle.hide();
}

function hideNavbar() {
  $navbar.hide();
  $navbarToggle.show();
}
