// Thanks to Brandon Keepers - 
describe('JSHint', function () {
  var options = {curly: true, white: false, indent: 2},
      files = /^\/public\/javascripts\/(models|collections|views)|.*spec\.js$/;

  function get(path) {
    path = path + "?" + new Date().getTime();

    var xhr;
    try {
      xhr = new jasmine.XmlHttpRequest();
      xhr.open("GET", path, false);
      xhr.send(null);
    } catch (e) {
      throw new Error("couldn't fetch " + path + ": " + e);
    }
    if (xhr.status < 200 || xhr.status > 299) {
      throw new Error("Could not load '" + path + "'.");
    }

    return xhr.responseText;
  }

  _.each(document.getElementsByTagName('script'), function (element) {
    var script = element.getAttribute('src');
    if (!files.test(script)) {
      return;
    }

    it(script, function () {
      var self = this;
      var source = get(script);
      var result = JSHINT(source, options);
      _.each(JSHINT.errors, function (error) {
        self.addMatcherResult(new jasmine.ExpectationResult({
          passed: false,
          message: "line " + error.line + ' - ' + error.reason + ' - ' + error.evidence
        }));
      });
      expect(true).toBe(true); // force spec to show up if there are no errors
    });

  });
});
