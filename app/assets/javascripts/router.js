if (typeof Fulcrum == 'undefined') {
  Fulcrum = {};
}

Fulcrum.Router = Backbone.Router.extend({

  routes: {
    'search?:params': 'search',
    '': 'home'
  }

});

Fulcrum.appRouter = new Fulcrum.Router();
