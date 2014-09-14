module = golem.module.member
module.component.list =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    golem.menus.secondary.items = [mi.list, mi.add, mi.tags, mi.skills]
    document.title = golem.utils.title l.MEMBERS_LIST
    @sort = (e) => golem.component.list.sort e, @items
    @search = (e) => @filteredItems = golem.component.list.search e, @items

    callback = (err, results) =>
      if err
        golem.notifications.helpers.errorUnexpected body: err
        @items = []
      else
        @items = results.rows
      m.endComputation()

    @tagFilter ?= false
    @setTagFilter = (tag) =>
      @tagFilter = tag
      m.startComputation()
      golem.model.getMembersByTag tag, callback

    @unsetTagFilter = =>
      @tagFilter = false
      getMembers()

    # Init
    @items = []
    getMembers = =>
      m.startComputation()
      golem.model.getBySchema 'member', callback

    module.data.getTags getMembers
    return

  view: (ctrl) ->
    l = golem.config.locale
    itemDom = (f) ->
      f = f.doc
      m 'tr', [
        m 'td', f.number
        m 'td', module.model.fullname f
        #m('td', f.family),
        m 'td', module.model.fulladdress f
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

    itemsDom = (if ctrl.filteredItems then ctrl.filteredItems.map itemDom else ctrl.items.map itemDom)
    gwf = golem.widgets.form
    mainContent = m 'section', { class: 'twelve wide column' }, [
      m 'table', { class: 'ui basic table' }, [
        m 'thead', [
          m 'tr', [
            gwf.sortTableHeaderHelper
              ctrl: ctrl
              field: 'number'
              title: 'MEMBER_NUMBER'
            gwf.sortTableHeaderHelper
              ctrl: ctrl
              field: 'lastname'
            gwf.sortTableHeaderHelper
              ctrl: ctrl
              field: 'city'
              title: 'ADDRESS'
            # m('th', l.FAMILY),
            m 'th', [
              l.TEL
              m 'i',
                class: 'icon info'
                title: l.DEFAULT_ONLY
            ]
            m 'th', [
              l.MAIL
              m 'i',
                class: 'icon info'
                title: l.DEFAULT_ONLY
            ]
            m 'th', { width: '10%' }, l.ACTIONS
          ]
        ]
        m 'tbody', itemsDom
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
