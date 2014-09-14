module = golem.module.activity
module.component.list =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    golem.menus.secondary.items = [mi.list, mi.add]
    document.title = golem.utils.title l.ACTIVITIES_LIST
    @items = []

    @sort = (e) => golem.component.list.sort e, @items
    @search = (e) => @filteredItems = golem.component.list.search e, @items

    callback = (err, results) =>
      if err
        golem.notifications.helpers.errorUnexpected body: err
        @items = []
        m.endComputation()
      else
        @items = results.rows
        golem.model.getMembersFromActivity null, (err, res) =>
          if err
            golem.notifications.helpers.errorUnexpected body: err
          else
            @takenPlacesByActivity = {}
            for r in res.rows
              aId = r.key[0]
              @takenPlacesByActivity[aId] ?= 0
              @takenPlacesByActivity[aId] += 1
          m.endComputation()

    getActivities = ->
      m.startComputation()
      golem.model.getBySchema 'activity', callback

    getActivities()
    return

  view: (ctrl) ->
    l = golem.config.locale

    placesDom = (i) ->
      color = 'inherit'
      if i.places
        remaining = i.places - ctrl.takenPlacesByActivity[i._id]
        color = switch
          when remaining <= 0 then 'red'
          when remaining < 5 then 'orange'
          else 'green'
      m 'span',
        style: { color: color },
        ctrl.takenPlacesByActivity[i._id]

    itemDom = (i) ->
      i = i.doc
      m 'tr', [
        m 'td', i.label
        m 'td', i.code
        m 'td', i.timeSlot
        m 'td', i.monitor
        m 'td', i.places
        m 'td', placesDom i
        m 'td.actions', [
          m 'a',
            href: '#/activity/show/' + i._id
            title: l.VIEW,
            [m 'i', { class: 'unhide icon' }]
          m 'a',
            href: '#/activity/edit/' + i._id
            title: l.EDIT,
            [m 'i', { class: 'edit icon' }]
          m 'a',
            href: '#/activity/remove/' + i._id
            title: l.DELETE,
            [m 'i', { class: 'remove icon' }]
        ]
      ]

    gwf = golem.widgets.form
    mainContent = m 'table', { class: 'ui basic table' }, [
      m 'thead', [
        m 'tr', [
          gwf.sortTableHeaderHelper ctrl: ctrl, field: 'label'
          gwf.sortTableHeaderHelper ctrl: ctrl, field: 'code'
          m 'th', l.TIMESLOT
          m 'th', l.MONITOR
          gwf.sortTableHeaderHelper ctrl: ctrl, field: 'places'
          m 'th', l.PLACES_TAKEN
          m 'th', { width: '10%' }, l.ACTIONS
        ]
      ]
      m 'tbody', (if ctrl.filteredItems then ctrl.filteredItems.map itemDom else ctrl.items.map itemDom)
    ]
    searchBox = golem.component.list.searchBox ctrl.search
    contextMenuContent = m 'nav', [
      m 'menu', { class: 'ui small vertical menu' }, [
        searchBox.head
        searchBox.content
      ]
    ]
    return [
      m 'section', { class: 'twelve wide column' }, [
        new golem.menus.secondary.view()
        mainContent
      ]
      m 'section', { class: 'four wide column' }, contextMenuContent
    ]
