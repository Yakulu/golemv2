module = golem.module.member
module.component.list =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    gcl = golem.component.list
    golem.menus.secondary.items = [mi.list, mi.add, mi.tags, mi.skills]
    document.title = golem.utils.title l.MEMBERS_LIST
    @sort = (e) => golem.component.list.sort e, @items
    @search = (e) =>
      value = e.target.value
      if value.length > 3
        @activeFilters.search = gcl.search.bind null, value
      else
        delete @activeFilters.search
      gcl.filter @

    callback = (err, results) =>
      if err
        golem.widgets.common.notifications.errorUnexpected body: err
        @items = []
      else
        @items = results.rows.map (r) -> new golem.Member r.doc
      m.endComputation()

    @filterByTag = (tag) =>
      if tag
        @tagFilter = tag
        @activeFilters.tags = (member) ->
          member.tags and tag in member.tags
      else
        @tagFilter = null
        delete @activeFilters.tags
      gcl.filter @

    # Init
    @items = []
    @filteredItems = null
    @activeFilters = {}
    getMembers = =>
      m.startComputation()
      golem.model.getBySchema 'member', callback

    module.data.getTags getMembers
    window.ctrl = @
    return

  view: (ctrl) ->
    l = golem.config.locale
    itemDom = (f) ->
      m 'tr', [
        m 'td', f.number
        m 'td', f.fullname()
        #m('td', f.family),
        m 'td', f.fulladdress()
        m 'td', f.tels.forEach (t) ->
          if t.default
            t.value.match(/\d{2}/g).join '.'
        m 'td', f.mails.map (mail) ->
          if mail.default
            m 'a', { href: 'mailto:' + mail.value }, mail.value
        m 'td.actions', [
          m 'a',
            href: '#/member/show/' + f._id
            title: l.VIEW,
            [m 'i', { class: 'unhide icon' }]
          m 'a',
            href: '#/member/edit/' + f._id
            title: l.EDIT,
            [m 'i', { class: 'edit icon' }]
          m 'a',
            href: '#/member/remove/' + f._id
            title: l.DELETE
            [m 'i', { class: 'remove icon' }]
        ]
      ]

    items = ctrl.filteredItems or ctrl.items
    gcl = golem.component.list
    mainContent = m 'section', { class: 'twelve wide column' }, [
      m 'table', { class: 'ui basic table' }, [
        m 'thead', [
          m 'tr', [
            gcl.sortTableHeaderHelper
              ctrl: ctrl
              field: 'number'
              title: 'MEMBER_NUMBER'
            gcl.sortTableHeaderHelper ctrl: ctrl, field: 'lastname'
            gcl.sortTableHeaderHelper
              ctrl: ctrl
              field: 'city'
              title: 'ADDRESS'
            # m('th', l.FAMILY),
            m 'th', [
              m 'span', l.TEL
              m 'i', { class: 'icon info', title: l.DEFAULT_ONLY }
            ]
            m 'th', [
              m 'span', l.MAIL
              m 'i', { class: 'icon info', title: l.DEFAULT_ONLY }
            ]
            m 'th', { width: '10%' }, l.ACTIONS
          ]
        ]
        m 'tbody', items.map itemDom
      ]
    ]
    searchBox = golem.component.list.searchBox ctrl.search
    tagsBox = golem.component.list.tagsBox module.data.tags, ctrl
    contextMenuContent = m 'section', { class: 'four wide column' },
      m 'nav', [
        m 'menu', { class: 'ui small vertical menu' }, [
          searchBox.head
          searchBox.content
          tagsBox.head
          tagsBox.tags
        ]
      ]
    return [
      m 'section', { class: 'twelve wide column' }, [
        new golem.menus.secondary.view()
        mainContent
      ]
      m 'section', { class: 'four wide column' }, contextMenuContent
    ]
