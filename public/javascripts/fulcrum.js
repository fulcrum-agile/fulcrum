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
});
