(function($){
  $.fn.filterStories = function() {
    var KEYCODES = {
      ENTER: 13
    };

    var input  = this.find('input#filter_bar');
    var cancel = this.find('#cancel');

    input.keydown(function(event) {
      if(event.keyCode == KEYCODES.ENTER) {
        var stories = $('.stories').find('div.story');
        var pattern = new RegExp(input.val(), 'i');

        $.each(stories, function() {
          story = $(this);
          if (!story.text().match(pattern)) {
            story.hide();
          } else {
            story.show();
          }
        });
      }
    });

    cancel.hide();
  };
})(jQuery);