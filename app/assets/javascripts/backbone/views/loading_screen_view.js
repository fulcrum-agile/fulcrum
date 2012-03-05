var LoadingScreenView = Backbone.View.extend({

  className: 'loading_screen',

  template: _.template(
              '<div class="spinner">' +
              '  <span class="icons-spinner"></span>' +
              '</div>'
            ),

  render: function() {
    $(this.el).html(this.template());
    return this;
  }

});

