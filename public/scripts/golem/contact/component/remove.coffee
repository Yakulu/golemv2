module = golem.module.contact
module.component.remove = golem.component.remove
  module: module
  class: golem.Contact,
  key: 'contactId'
  nameFn: (item) -> item.fullname()
  confirm: 'CONTACTS_REMOVE_CONFIRM_MSG'
  route: '/contact/list'
