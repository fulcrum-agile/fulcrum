var executeAttachinary = require('libs/execute_attachinary');
var KeycutView = require('views/keycut_view');

$(function() {
  $('.toggle-navbar').click(function(e) {
      e.preventDefault();

      if($("#navbar").is(':hidden')) {
        showNavbar();
      } else {
        hideNavbar()
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

  $("#sidebar-wrapper").mouseenter(function() {
    var sidebar = $(this);
    var timeoutId = setTimeout(function() {
      sidebar.toggleClass("open");
    }, 500);
    sidebar.mouseleave(function() {
      clearTimeout(timeoutId);
      sidebar.removeClass("open");
    });
  });
  
  $("#sidebar-toggle").click(function(e) {
    e.preventDefault();
    var wrapper = $("#sidebar-wrapper");
    
    if (wrapper.hasClass('collapsed') == true) 
      $(this).html('<i class="mi md-18 mi--sidebar">close</i>');
    else 
      $(this).html('<i class="mi md-18 mi--sidebar">menu</i>');
    
    wrapper.toggleClass('collapsed')
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
  $('#navbar').show();
  $('.toggle-navbar.more').hide();
  $('.toggle-navbar.less').show();
}

function hideNavbar() {
  $('#navbar').hide();
  $('.toggle-navbar.more').show();
  $('.toggle-navbar.less').hide();
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
