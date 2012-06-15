$(function() {
  $('#add_story').click(function() {
    window.projectView.newStory();

    // Show chilly bin if it's hidden
    $('.hide_chilly_bin.pressed').click();
    var newStoryElement = $('#chilly_bin div.story:last');
    $('#chilly_bin').scrollTo(newStoryElement, 100);
  });

  $('#backlog').sortable('option', 'connectWith', '#chilly_bin,#in_progress');
  $('#chilly_bin').sortable('option', 'connectWith', '#backlog,#in_progress');
  $('#in_progress').sortable('option', 'connectWith', '#backlog,#chilly_bin');

  // Add close button to flash messages
  $('#messages div').prepend('<a class="close" href="#">×</a>').find('a.close').click(function () {
    $(this).parent().slideUp();
    return false;
  });
});
