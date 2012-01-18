var LoadingScreenView = Backbone.View.extend({

  className: 'loading_screen',

  template: _.template(
              '<div class="spinner">' +
              '  <img src="/images/spinner.gif" />' +
              '</div>'
            ),

  render: function() {
    $(this.el).html(this.template());
    return this;
  }

});

