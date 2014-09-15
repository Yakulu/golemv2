module = golem.module.member
module.component.remove = golem.component.remove
  module: module
  class: golem.Member,
  key: 'memberId'
  nameFn: (item) -> item.fullname()
  confirm: 'MEMBERS_REMOVE_CONFIRM_MSG'
  route: '/member/list'
