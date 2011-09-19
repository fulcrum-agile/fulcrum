$(function() {
  $('#add_story').click(function() {
    window.projectView.model.stories.add([{
      title: "New story", events: [], editing: true
    }]);

    // Show chilly bin if it's hidden
    $('.hide_chilly_bin.pressed').click();
    var newStoryElement = $('#chilly_bin div.story:last');
    $('#chilly_bin').scrollTo(newStoryElement, 100);
  });

  $('div.sortable').sortable({
    handle: '.story-title', opacity: 0.6,

    items: ".story:not(.accepted)",

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

  $('#backlog').sortable('option', 'connectWith', '#chilly_bin,#in_progress');
  $('#chilly_bin').sortable('option', 'connectWith', '#backlog,#in_progress');
  $('#in_progress').sortable('option', 'connectWith', '#backlog,#chilly_bin');

  // Add close button to flash messages
  $('#messages div').prepend('<a class="close" href="#">×</a>').find('a.close').click(function () { 
    $(this).parent().fadeOut(); 
    return false;
  });
});
