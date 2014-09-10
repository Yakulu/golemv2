(function () {
  // TODO : integrity checks with members...
  var module = golem.module.activity;
  module.component.remove = golem.component.remove({
    module: module,
    key: 'activityId',
    nameFn: function (item ) { return item.label; },
    confirm: 'ACTIVITIES_REMOVE_CONFIRM_MSG',
    route: '/activity/list'
  });
}).call(this);
