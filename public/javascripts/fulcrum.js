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

  $('thead a.toggle-column, #column-toggles a').click(function(el){
    //Find relevant column from class name
    var className = _.detect( el.target.classList, function(elClass){ return elClass.match(/hide_\w+/) });
    $('.'+className.replace(/hide_/,'')+'_column').toggle();
    $("#column-toggles").find( "."+className ).toggleClass('pressed');
  })

  $('#backlog').sortable('option', 'connectWith', '#chilly_bin');
  $('#chilly_bin').sortable('option', 'connectWith', '#backlog');
});
