(function($){
  $.fn.filterStories = function() {
    var KEYCODES = {
      ENTER: 13
    };

    var input = this;

    input.keydown(function(event) {
      if(event.keycode == KEYCODES.ENTER) {
        var stories = $('.stories').find('div.story');
        var pattern = new RegExp(input.val(), 'i');

        $.each(stories, function() {
          story = $(this);
          if (!story.html().match(pattern)) {
            story.hide();
          } else {
            story.show();
          }
        });
      }
    });
  };
})(jQuery);