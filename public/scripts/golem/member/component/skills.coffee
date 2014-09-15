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
      helpMsg: l.SKILLS_MANAGEMENT_HELP_MSG
      removeMsg: l.SKILLS_MANAGEMENT_REMOVE_MSG

  view: (ctrl) ->
    new golem.component.tags.view ctrl
