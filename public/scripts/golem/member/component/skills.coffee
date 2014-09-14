member = golem.module.member
member.component.skills =
  controller: ->
    l = golem.config.locale
    new golem.component.tags.controller
      menuItems: member.data.menuItems
      title: l.SKILLS_MANAGEMENT
      field: 'skills'
      getTagsFn: member.data.getSkills
      getDocsKey: 'memberskills'
      removeMsg: l.TAGS_MANAGEMENT_HELP_MSG

  view: (ctrl) ->
    new golem.component.tags.view ctrl
