$(function() {
  $('#add_story').click(function() {
    window.projectView.newStory();

    // Show chilly bin if it's hidden
    $('.hide_chilly_bin.pressed').click();
    var newStoryElement = $('#chilly_bin div.story:last');
    $('#chilly_bin').scrollTo(newStoryElement, 100);
  });

  // Add close button to flash messages
  $('#messages div').prepend('<a class="close" href="#">×</a>').find('a.close').click(function () {
    $(this).parent().fadeOut();
    return false;
  });
  
  // keycut listener
  $('html').keypress(function(event){
      var code = event.which || event.keyCode;
      var keyChar = String.fromCharCode(code);
      switch (code) {
        case 63: // ? | Should only work without a focused element
          if (!$(':focus').length) {
            if ($('#keycut-help').length) {
              $('#keycut-help').fadeOut(function(){$('#keycut-help').remove();});
            } else {
              new Fulcrum.KeycutView().render();
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
          $('.story.editing').find('#submit').click()
        default:
          // whatever
      };
    });
});