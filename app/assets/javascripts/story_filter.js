(function($){
  $.fn.filter = function() {
    var KEYCODES = {
      ENTER: 13
    };

    var input = this;
    var stories = $('.stories');

    input.keydown(function(event) {
      if(event.keycode == KEYCODES.ENTER) {
        stories.find('div.story:not(contains(' + input.val() + '))').hide();
        stories.find('div.story:contains(' + input.val() + ')').show();
      }
    });
  };
})(jQuery);