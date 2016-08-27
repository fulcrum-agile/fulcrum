$(function() {
  $('[data-column-view]').each(function() {
    var data = $(this).data();
    var column = new Fulcrum.ColumnView({
      el: $(this),
      id: data.columnView,
      name: I18n.t('projects.show.' + data.columnView),
      sortable: data.connect !== undefined
    }).render();

    if (data.hideable !== false) {
      $("<li></li>").
      append(new Fulcrum.ColumnVisibilityButtonView({ columnView: column }).render().$el).
      appendTo('#column-toggles');
    }

    if (data.connect) {
      column.$el
        .find('.ui-sortable')
        .sortable('option', 'connectWith', data.connect);
    }

    $(this).addClass(data.columnView + '_column');
  });

  $('[data-project]').each(function() {
    var data = $(this).data();
    var project = new Fulcrum.Project(data.project);
    var view = new Fulcrum.ProjectView({ model: project });
    var search = new Fulcrum.ProjectSearchView({ model: project, el: $('#form_search') });
    var velocity = new Fulcrum.ProjectVelocityView({ model: project, el: $('#velocity') });

    project.users.reset(data.users);
    project.current_user = new Fulcrum.User(data.currentUser);

    view.velocityView = velocity;
    view.searchView = search;
    view.scaleToViewport();
    $(window).resize(view.scaleToViewport);

    setInterval(function() { project.fetch(); }, 10 * 1000); // every 10 seconds

    window.md = new Markdown.Converter();
    window.projectView = view;
  });
});
