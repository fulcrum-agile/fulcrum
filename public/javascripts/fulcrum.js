$(function(){
  // The 'Add story button' should show the hidden form at the bottom of the
  // backlog
  $('#new_story').hide();
  $('#add_story').click(function() {
    $('#new_story').toggle();
    $('#story_title').focus();
    return false;
  });
});
