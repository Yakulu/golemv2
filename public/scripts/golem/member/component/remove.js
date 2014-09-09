(function () {
  var module = golem.module.member;
  module.component.remove = golem.component.remove({
    module: module,
    key: 'memberId',
    nameFn: module.model.fullname,
    confirm: 'MEMBERS_REMOVE_CONFIRM_MSG',
    route: '/member/list'
  });
}).call(this);
