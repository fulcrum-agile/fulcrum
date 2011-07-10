$(function() {
  $('#add_story').click(function() {
    window.Project.stories.add([{
      title: "New story", events: [], editing: true
    }]);

    // TODO - This needs some improvement, scroll into view
    var newStoryElement = $('#chilly_bin div.story:last');
    $('#chilly_bin').scrollTop(newStoryElement.position().top);
  });

  $('div.sortable').sortable({
    handle: '.story-title', opacity: 0.6,

    update: function(ev, ui) {
      ui.item.trigger("sortupdate", ev, ui);
    }

  });

  $('#backlog').sortable('option', 'connectWith', '#chilly_bin');
  $('#chilly_bin').sortable('option', 'connectWith', '#backlog');

  // Automatically generate user initials based on Name field
  $('form#user_new input#user_name').keyup(function() {
    var user_name = $(this).val();
    // Split Name field on spaces, collect first letters, join, convert to upper case. E.g. Joe Arthur Bloggs => JAB
    var user_initials = _.map(user_name.split(' '), function(n) { return n[0]}).join('').toUpperCase();
    $('form#user_new input#user_initials').val(user_initials);
  });
});

