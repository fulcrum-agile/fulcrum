var Project = require('models/project');
var User = require('models/user');

var ColumnView = require('views/column_view');
var ColumnVisibilityButtonView = require('views/column_visibility_button_view');
var ProjectView = require('views/project_view');
var ProjectSearchView = require('views/project_search_view');
var ProjectVelocityView = require('views/project_velocity_view');

require('./global_listeners');

var Central = module.exports = {
  start: function() {
    var columnViews = {};

    $('[data-column-view]').each(function() {
      var data = $(this).data();
      var column = new ColumnView({
        el: $(this),
        id: data.columnView,
        name: I18n.t('projects.show.' + data.columnView),
        sortable: data.connect !== undefined
      });
      columnViews[data.columnView] = column;
      column.render();

      if (data.hideable !== false) {
        $('<li/>')
          .append(new ColumnVisibilityButtonView({ columnView: column }).render().$el)
          .appendTo('#column-toggles');
      }

      if (data.connect) {
        column.$el
          .find('.ui-sortable')
          .sortable('option', 'connectWith', data.connect);
      }

      $(this).addClass(data.columnView + '_column');
    });

    $('[data-project]').each(function() {
      var data     = $(this).data();
      var project  = new Project(data.project);
      var view     = new ProjectView({ model: project });
      var search   = new ProjectSearchView({ model: project, el: $('#form_search') });
      var velocity = new ProjectVelocityView({ model: project, el: $('#velocity') });

      project.users.reset(data.users);
      project.current_user = new User(data.currentUser);

      view.addColumnViews(columnViews);
      view.velocityView = velocity;
      view.searchView   = search;
      view.scaleToViewport();
      $(window).resize(view.scaleToViewport);

      setInterval(function() {
        project.fetch();
      }, 10 * 1000); // every 10 seconds

      window.projectView = view;
    });
  }
};
