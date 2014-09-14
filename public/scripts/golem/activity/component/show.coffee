module = golem.module.activity
module.component.show =
  controller: ->
    l = golem.config.locale
    key = m.route.param 'activityId'
    m.startComputation()
    golem.model.db.get key, (err, res) =>
      if err
        golem.notifications.helpers.error body: l.ERROR_RECORD_NOT_FOUND
        m.route '/member/list'
        m.endComputation()
      else
        @activity = res
        document.title = golem.utils.title(l.DETAILS) + @activity.label
        mi = module.data.menuItems
        for action in ['show', 'edit', 'remove']
          mi[action].url = "#{mi[action].baseUrl}/#{@activity._id}"

        golem.menus.secondary.items = [
          mi.list
          mi.add
          mi.show
          mi.edit
          mi.remove
        ]
        golem.model.getMembersFromActivity @activity._id, (err, res) =>
          if err
            golem.notifications.helpers.errorUnexpected body: err
            @members = []
          else
            @members = res.rows
          m.endComputation()
    return

  view: (ctrl) ->
    l = golem.config.locale
    a = ctrl.activity
    activityMembersContent = do ->
      if ctrl.members.length > 0
        m 'ul', { class: 'ui list' }, ctrl.members.map((i) ->
          fullname = golem.module.member.model.fullname i.doc
          m 'li', [
            m 'a', { href: '#/member/show/' + i.doc._id }, fullname
          ]
        )
      else
        m 'p', l.NONE

    mainContent = m 'section', { class: 'ui piled segment' }, [
      m 'h2', a.label
      m 'p', a.note
      m 'div', { class: 'ui horizontal list' }, [
        m 'div.item', [
          m 'div.content', [
            m 'div.header', l.CODE
            m 'div.description', a.code
          ]
        ]
        m 'div.item', [
          m 'div.content', [
            m 'div.header', l.TIMESLOT
            m 'div.description', a.timeSlot
          ]
        ]
        m 'div.item', [
          m 'div.content', [
            m 'div.header', l.MONITOR
            m 'div.description', a.monitor
          ]
        ]
        m 'div.item', [
          m 'div.content', [
            m 'div.header', l.PLACES
            m 'div.description', a.places
          ]
        ]
        m 'div.item', [
          m 'div.content', [
            m 'div.header', l.PLACES_TAKEN
            m 'div.description', ctrl.members.length
          ]
        ]
        m 'div.item', [
          m 'div.content', do ->
            if a.places
              [
                m 'div.header', l.PLACES_REMAIN
                m 'div.description', (a.places - ctrl.members.length)
              ]
        ]
      ]
      m 'h3', l.ACTIVITIES_MEMBERS
      activityMembersContent
    ]
    return [
      m 'section', { class: 'sixteen wide column' }, [
        new golem.menus.secondary.view()
        mainContent
      ]
    ]
