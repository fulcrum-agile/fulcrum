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
    var keyCode = event.which || event.keyCode;
    var keyChar = String.fromCharCode(keyCode);
    //alert(keyChar + ":" + keyCode);
    switch (keyCode) {
      case 63: // ?
        if ($('#keycut-help').length) {
          $('#keycut-help').fadeOut(function(){$('#keycut-help').remove();});
        } else {
          new Fulcrum.KeycutView().render();
        };
        break;
      case 97: // a
        if (window.projectView) {
          window.projectView.newStory();
          $('.hide_chilly_bin.pressed').click();
          var newStoryElement = $('#chilly_bin div.story:last');
          $('#chilly_bin').scrollTo(newStoryElement, 100);
          return false;
        };
        break;
      default:
        // whatever
    };
  });
});