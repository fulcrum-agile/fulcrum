(function($){
  $.fn.filterStories = function() {
    var KEYCODES = {
      ENTER: 13
    };

    var input  = this.find('input#filter_bar');
    var cancel = this.find('.icons-cancel');
    var stories;

    cancel.hide();

    input.keydown(function(event) {
      stories = $('.stories div.story');
      if(event.keyCode == KEYCODES.ENTER) {
        var pattern = new RegExp(input.val(), 'i');

        $.each(stories, function() {
          story = $(this);
          if (story.is(':visible') && !story.text().match(pattern)) {
            story.hide();
          } else if(story.is(':hidden') && story.text().match(pattern)) {
            story.show();
          }
        });
      }
    });

    input.keyup(function(event) {
      if(input.val() != "") {
        cancel.show();
      } else {
        unfilter();
      }
    });

    cancel.click(function() {
      input.val("");
      unfilter();
    });

    var unfilter = function() {
      cancel.hide();
      $('.stories div.story:hidden').show();
    };
  };
})(jQuery);