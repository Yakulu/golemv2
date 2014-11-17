module = golem.module.contact
module.component.show =
  controller: ->
    l = golem.config.locale
    key = m.route.param 'contactId'
    initController = =>
      document.title = golem.utils.title l.DETAILS + @contact.fullname()
      mi = module.data.menuItems
      ['show', 'edit', 'remove'].forEach (action) =>
        mi[action].url = "#{mi[action].baseUrl}/#{@contact._id}"

      golem.menus.secondary.items = [mi.list, mi.add, mi.show, mi.edit, mi.remove]
      m.endComputation()

    m.startComputation()
    golem.model.db.get key, (err, res) =>
      if err
        golem.widgets.common.notifications.warning body: l.ERROR_RECORD_NOT_FOUND
        m.route '/contact/list'
        m.endComputation()
      else
        @contact = new golem.Contact res
        initController()
    return

  view: (ctrl) ->
    l = golem.config.locale
    f = ctrl.contact
    gcs = golem.component.show
    columnLeftContent = [
      m 'p', [
        m 'div', { class: 'ui label teal' }, l.CONTACT_DETAILS
        m 'div', f.fulladdress()
      ]
    ]
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
      ]
      m 'h2', [
        m 'span', f.fullname()
      ]
      m 'p', { class: 'ui basic segment' }, f.note # m.trust f.note
      m 'div', { class: 'ui two column grid' }, [
        m 'div.column', columnLeftContent
        m 'div.column', [
          m 'p', [
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
