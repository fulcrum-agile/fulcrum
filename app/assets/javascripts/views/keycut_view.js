if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.KeycutView = Backbone.View.extend({
  template: JST['templates/keycut_view'],
  tagName: 'div',
  id: 'keycut-help',
  
  events:  {
    'click a.close' : 'closeWindow'
  },
  
  render: function() {
    $('#main').append($(this.el).html(this.template));
    return this;
  },
  
  closeWindow : function(){
    $('#'+this.id).fadeOut(
      function() {$('#'+this.id).remove();}
    );
  }
});