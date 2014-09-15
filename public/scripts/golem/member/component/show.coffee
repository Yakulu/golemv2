module = golem.module.member
module.component.show =
  controller: ->
    l = golem.config.locale
    key = m.route.param 'memberId'
    initController = =>
      document.title = golem.utils.title l.DETAILS + @member.fullname()
      mi = module.data.menuItems
      ['show', 'edit', 'remove'].forEach (action) =>
        mi[action].url = "#{mi[action].baseUrl}/#{@member._id}"

      golem.menus.secondary.items = [mi.list, mi.add, mi.show, mi.edit, mi.remove]
      m.endComputation()

    m.startComputation()
    golem.model.db.get key, (err, res) =>
      if err
        golem.widgets.common.notifications.warning body: l.ERROR_RECORD_NOT_FOUND
        m.route '/member/list'
        m.endComputation()
      else
        @member = new golem.Member res
        if @member.activities.length > 0
          golem.model.db.allDocs
            keys: @member.activities
            include_docs: true,
            (err, res) =>
              if err
                @selectedActivities = null
                golem.widgets.common.notifications.errorUnexpected body: err
              else
                @selectedActivities = res.rows.map (r) -> new golem.Activity r.doc
              initController()
        else
          @selectedActivities = null
          initController()
    return

  view: (ctrl) ->
    l = golem.config.locale
    f = ctrl.member
    gcs = golem.component.show
    civilityContent = do ->
      items = []
      if f.gender
        genderLocale = (if (f.gender is 'm') then l.GENDER_MALE else l.GENDER_FEMALE)
        li = m 'li.item', "#{l.GENDER} #{genderLocale.toLowerCase()}"
        items.push li
      items.push m 'li.item', l.BORN + moment(f.birthday).format('L') if f.birthday
      items.push m 'li.item', "#{l.NATIONALITY} #{f.nationality}" if f.nationality
      items.push m 'li.item', f.profession if f.profession
      items
    columnLeftContent = [
      m 'p', [
        m 'div', { class: 'ui label purple' }, l.CIVILITY
        m 'ul', { class: 'ui bulleted list' }, civilityContent
      ]
      m 'p', [
        m 'div', { class: 'ui label teal' }, l.CONTACT_DETAILS
        m 'div', f.fulladdress()
      ]
    ]
    if f.guardianLastname
      yesNo = (bool) -> (if bool then l.YES else l.NO)

      minorContent = m 'p', [
        m 'div', { class: 'ui label green' }, l.MINOR
        m 'p', "#{l.CHILD_GUARDIAN} : #{f.guardianLastname} #{f.guardianFirstname}"
        m 'div', l.AUTHORIZATIONS
        m 'ul', { class: 'ui bulleted list' }, [
          m 'li.item', "#{l.ACTIVITIES_PARTICIPATION} : #{yesNo(f.authorizations.activities)}"
          m 'li.item', "#{l.AUTHORIZATIONS_PHOTOS} : #{yesNo(f.authorizations.photos)}"
        ]
      ]
      columnLeftContent.push minorContent
    communication = ->
      fcm = f.communicationModes
      return ''  if f.tels.length is 0 and f.mails.length is 0
      content = "#{l.COMMUNICATION_MODES_ACCEPTANCE}:"
      if not fcm.mail and not fcm.tel
        content += ' ' + l.NONE
        content = "#{content} #{l.NONE}"
      else
        content = "#{content} #{l.MAIL}" if fcm.mail
        content = "#{content} #{l.TEL}" if fcm.tel
      content

    selectedActivities = ->
      return l.NONE_F  unless ctrl.selectedActivities
      m 'ul', { class: 'ui list' }, ctrl.selectedActivities.map (a) ->
        m 'li', [
          m 'a', { href: '#/activity/show/' + a._id }, a.label
        ]

    mainContent = m 'section', { class: 'ui piled segment' }, [
      m 'div', { class: 'ui floated right basic segment' }, [
        m 'p', do ->
          tagsItems = f.tags.map (tag) ->
            m 'span',
              class: 'ui small teal label golem-tag'
              title: l.MEMBERS_BY_TAGS,
              [ m 'i', { class: 'tag icon' }, tag ]
          tagsItems.unshift m 'span', l.TAGS + ' ' if tagsItems.length > 0
          tagsItems
        m 'p', do ->
          skillsItems = f.skills.map (skill) ->
            m 'span',
              class: 'ui small blue label golem-tag'
              title: l.MEMBERS_BY_SKILLS,
              skill
          skillsItems.unshift m 'span', l.SKILLS + ' ' if skillsItems.length > 0
          skillsItems
      ]
      m 'h2', [
        m 'span', f.fullname()
        m 'span', (if f.number then " (#{f.number})" else '')
      ]
      m 'p', { class: 'ui basic segment' }, f.note # m.trust f.note
      m 'div', { class: 'ui two column grid' }, [
        m 'div.column', columnLeftContent
        m 'div.column', [
          m 'p', [
            m 'div', { class: 'ui label red' }, l.ACTIVITIES
            m 'p', selectedActivities()
            m 'div', { class: 'ui label purple' }, l.COMMUNICATION_MODES
            m 'p', communication()
            gcs.multiBox f.tels, l.TELS, gcs.format.tels
            gcs.multiBox f.mails, l.MAILS, gcs.format.mails
          ]
        ]
      ]
    ]
    return [
      m 'section', { class: 'sixteen wide column' }, [
        new golem.menus.secondary.view()
        mainContent
      ]
    ]
