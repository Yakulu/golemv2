(function () {
  var module = golem.module.contact;
  module.component.remove = golem.component.remove({
    module: module,
    key: 'contactId',
    nameFn: module.model.fullname,
    confirm: 'CONTACTS_REMOVE_CONFIRM_MSG',
    route: '/contact/list'
  });
}).call(this);
