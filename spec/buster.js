var config = module.exports;

config["Fulcrum"] = {
    environment: "browser",        // or "node"
    rootPath: "..",
    sources: [
      "spec/javascripts/support/buster-setup.js",
      "spec/javascripts/support/jst-stubs.js",
      "spec/javascripts/lib/jquery.js",
      "spec/javascripts/lib/jquery-ui.js",
      "vendor/assets/javascripts/underscore.js",
      "vendor/assets/javascripts/backbone.js",
      "vendor/assets/javascripts/backbone.rails.js",
      "vendor/assets/javascripts/bootstrap-twipsy.js",
      "vendor/assets/javascripts/bootstrap-popover.js",
      "vendor/assets/javascripts/tag-it.js",
      "app/assets/javascripts/backbone/models/*.js",
      "app/assets/javascripts/backbone/collections/*.js",
      "app/assets/javascripts/backbone/views/*.js",
    ],
    tests: [
        "spec/javascripts/**/*.spec.js"
    ]
}
