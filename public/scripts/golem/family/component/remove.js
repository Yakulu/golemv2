(function () {
  var module = golem.module.family;
  module.component.remove = golem.component.remove({
    module: module,
    key: 'familyId',
    nameFn: function (f) { return f.lastname; },
    confirm: 'CONTACTS_REMOVE_CONFIRM_MSG',
    route: '/family/list'
  });
}).call(this);
