describe("$.filterStories", function() {
  var main_container, filter_container, input, cancel, stories_table;
  var story1, story2, keydown, keyup;

  beforeEach(function() {
    keydown = $.Event('keydown');
    keydown.keyCode = 13;

    filter_container = $('<div id="filter"></div>');
    input  = $('<input id="filter_bar" placeholder="Filter stories..." />');
    cancel = $('<span class="icon icons-cancel">Cancel</span>');
    filter_container.append(input).append(cancel);

    stories_table = $('<table class="stories"></table>');
    story1 = $('<div id="1" class="story"><div class="story-title">Story with first keyword</div></div>');
    story2 = $('<div id="2" class="story"><div class="story-title">Story with second keyword</div></div>');
    stories_table.append(story1).append(story2);

    main_container   = $('<div></div>');
    main_container.append(filter_container).append(stories_table);
    setFixtures(main_container);

    filter_container.filterStories();
  });

  describe("filtering stories based on keywords", function() {
    $.each(['first keyword', 'FiRst KeyworD'], function(index, keyword) {
      it("should hide stories that don't match the keywords, ignoring cases", function() {
        input.val(keyword);
        input.trigger(keydown);

        expect(story1).toBeVisible();
        expect(story2).not.toBeVisible();
      });
    });

    it("should show or unhide stories that match the keywords", function() {
      story2.hide();

      input.val("second keyword");
      input.trigger(keydown);

      expect(story1).not.toBeVisible();
      expect(story2).toBeVisible();
    });
  });

  describe("edge cases", function() {
    it("should show all stories when the filter bar is empty", function() {
      input.val("");
      input.trigger(keydown);
      expect(story1).toBeVisible();
      expect(story2).toBeVisible();
    });

    it("should not match html code", function() {
      input.val("div");
      input.trigger(keydown);
      expect(story1).not.toBeVisible();
      expect(story2).not.toBeVisible();
    });
  });

  describe("cancel", function() {
    beforeEach(function() {
      keyup   = $.Event('keyup');
      keyup.keyCode = 8;
    });

    it("should only appear when there are keywords inside the filter bar", function() {
      input.val("somethin");
      keyup.keyCode = 71; //character 'g'
      input.trigger(keyup);
      expect(cancel).toBeVisible();

      input.val(""); //triggerring backspace, does not really erase the input. Faking it for now.
      keyup.keyCode = 8;
      input.trigger(keyup);
      expect(story1).toBeVisible();
      expect(story2).toBeVisible();

      expect(cancel).not.toBeVisible();
    });

    it("should empty the filterbar when clicked", function() {
      input.val("something");
      cancel.show();

      cancel.trigger("click");
      expect(cancel).not.toBeVisible();

      expect(input).toHaveValue("");
    });

    it("should show all stories when clicked", function() {
      story1.hide();
      input.val("");
      cancel.trigger("click");

      expect(story1).toBeVisible();
      expect(story2).toBeVisible();
    });
  });

  describe("backspace", function() {
    it("should show all hidden stories when pressed when input bar is empty", function() {
      story1.hide();
      story2.hide();

      input.val("");
      keyup   = $.Event('keyup');
      keyup.keyCode = 8;
      input.trigger(keyup);

      expect(story1).toBeVisible();
      expect(story2).toBeVisible();
    });
  });
});