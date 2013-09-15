if (typeof Fulcrum == 'undefined') {
    Fulcrum = {};
}

Fulcrum.ApiTokenView = Backbone.View.extend({

    template: JST['templates/api_token'],
    events: {
        'click .api_token_button' : "generateAuthToken"
    },

    initialize: function(){
        _.bindAll(this, "render");
        this.model.bind("sync", this.render);
    },

    generateAuthToken: function() {
        this.model.save("new_api_token", true)
    },

    render: function() {
        this.$el.html(this.template({api_token: this.model.get('api_token')}));
        return this;
    }
});