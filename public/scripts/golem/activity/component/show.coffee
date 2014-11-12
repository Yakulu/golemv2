module = golem.module.activity
module.component.show =
  controller: ->
    l = golem.config.locale
    key = m.route.param 'activityId'

    @csvExport = =>
      activityName = "#{@activity.fullLabel()} - #{@activity.monitor}"
      preCSV = ["\"#{activityName}\""]
      items = (_.clone item for item in @members)
      schema =
        number: l.MEMBER_NUMBER
        lastname: l.LASTNAME
        firstname: l.FIRSTNAME
        address: l.ADDRESS
        postalCode: l.POSTAL_CODE
        city: l.CITY
        mails: l.MAILS
        tels: l.TELS
      for item in items
        for field, locale of schema
          switch field
            when 'tels', 'mails'
              values = ("#{v.label}: #{v.value}" for v in item[field])
              item[field] = values.join ','
            else
              item[field] ?= ''
      golem.component.list.csvExport items, schema, "#{@activity.code}-activity-members", preCSV

    m.startComputation()
    golem.model.db.get key, (err, res) =>
      if err
        golem.widgets.common.notifications.warning body: l.ERROR_RECORD_NOT_FOUND
        m.route '/member/list'
        m.endComputation()
      else
        @activity = new golem.Activity res
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
            golem.widgets.common.notifications.errorUnexpected body: err
            @members = []
          else
            @members = res.rows.map (r) -> new golem.Member r.doc
          m.endComputation()
    return

  view: (ctrl) ->
    l = golem.config.locale
    a = ctrl.activity
    activityMembersContent = do ->
      if ctrl.members.length > 0
        m 'ul', { class: 'ui list' }, ctrl.members.map (i) ->
          m 'li', [
            m 'a', { href: '#/member/show/' + i._id }, i.fullname()
            m 'span', ' ' + i.fulladdress()
            m 'span', do ->
              if i.tels.length > 0
                ' (tel ' + (v.value for v in i.tels when v.default) + ')'
            m 'span', do ->
              if i.mails.length > 0
                ' (mail ' + (v.value for v in i.mails when v.default) + ')'
          ]
      else
        m 'p', l.NONE

    mainContent = m 'section', { class: 'ui piled segment' }, [
      m 'h2', [
        a.label + ' '
        m 'i',
          title: l.CSV_EXPORT
          class: 'text file outline icon'
          style: cursor: 'pointer'
          onclick: ctrl.csvExport
      ]
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
