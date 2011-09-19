$(function() {
  $('#add_story').click(function() {
    window.Project.stories.add([{
      title: "New story", events: [], editing: true
    }]);

    var newStoryElement = $('#chilly_bin div.story:last');
    $('#chilly_bin').scrollTo(newStoryElement, 100);
  });

  $('div.sortable').sortable({
    handle: '.story-title', opacity: 0.6,

    items: ".story",

    update: function(ev, ui) {
      ui.item.trigger("sortupdate", ev, ui);
    }

  });

  $('#backlog').sortable('option', 'connectWith', '#chilly_bin');
  $('#chilly_bin').sortable('option', 'connectWith', '#backlog');
});
