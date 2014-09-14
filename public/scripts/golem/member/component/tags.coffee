member = golem.module.member
member.component.tags =
  controller: ->
    l = golem.config.locale
    new golem.component.tags.controller
      menuItems: member.data.menuItems
      title: l.TAGS_MANAGEMENT
      getTagsFn: member.data.getTags
      getDocsKey: 'member'
      removeMsg: l.TAGS_MANAGEMENT_HELP_MSG

  view: (ctrl) ->
    new golem.component.tags.view ctrl
