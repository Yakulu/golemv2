contact = golem.module.contact
contact.component.tags =
  controller: ->
    l = golem.config.locale
    new golem.component.tags.controller
      menuItems: contact.data.menuItems
      title: l.TAGS_MANAGEMENT
      getTagsFn: contact.data.getTags
      getDocsKey: 'contact'

  view: (ctrl) ->
    new golem.component.tags.view ctrl
