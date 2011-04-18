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

/**
 * Loads an entire column from a remote data path.  path is the path of the
 * url to call, column_id is the element id to append the data to.
 */
function loadColumn(path, column_id) {
  $.ajax({
    dataType: "json",
    url: path,
    success: function(stories) {
      $('#story_tmpl').tmpl(stories).appendTo(column_id);
    }
  });
}
