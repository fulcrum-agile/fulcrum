describe("filtering stories", function() {
  beforeEach(function() {
    keydown = $.Event('keydown');
    keydown.keycode = 13;
  });

  describe("$.filter", function() {
    var main_container, input, filter;
    var story1, story2;

    beforeEach(function() {
      main_container = $('<div></div>');

      input = $('<input id="filter_bar" placeholder="Filter stories..." />');

      storiesTable = $('<table class="stories"></table>');
      story1 = $('<div id="1" class="story"><div class="story-title">Story with first keyword</div></div>');
      story2 = $('<div id="2" class="story"><div class="story-title">Story with second keyword</div></div>');

      storiesTable.append(story1).append(story2);
      main_container.append(input).append(storiesTable);
      setFixtures(main_container);

      input.filter();
    });

    it("should hide stories that don't match the keywords", function() {
    });

    xit("should unhide stories that match the keywords", function() {});
  });
});