(function($){
  $.fn.filterStories = function() {
    var KEYCODES = {
      ENTER: 13
    };

    var input = this;
    var stories = $('.stories');

    input.keydown(function(event) {
      if(event.keycode == KEYCODES.ENTER) {
        var pattern = new RegExp(input.val(), 'i');

        stories.find('div.story').filter(function() {
          return !$(this).html().match(pattern);
        }).hide();
        stories.find('div.story:contains(' + input.val() + ')').show();
      }
    });
  };
})(jQuery);