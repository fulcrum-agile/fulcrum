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

  $('#show_hide_buttons a').click(function(el){
    var button = el.target;
    var id = button.id.replace('hide_','');
    $(button).toggleClass('pressed');
    $('#'+id+'_column').toggle();
    $('#'+id+'_header').toggle();
  })

  $('#backlog').sortable('option', 'connectWith', '#chilly_bin');
  $('#chilly_bin').sortable('option', 'connectWith', '#backlog');
});
