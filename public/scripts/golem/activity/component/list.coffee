module = golem.module.activity
module.component.list =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    gcl = golem.component.list
    golem.menus.secondary.items = [mi.list, mi.add]
    document.title = golem.utils.title l.ACTIVITIES_LIST
    @items = []
    @filteredItems = null
    @activeFilters = {}
    @searchAdvancedOn = false
    @searches = label: m.prop(''), code: m.prop(''), monitor: m.prop('')

    @sort = (e) => golem.component.list.sort e, @items

    @searchGlobal = (e) =>
      value = e.target.value
      if value.length > 3
        @activeFilters.search = gcl.search.bind null, value
      else
        delete @activeFilters.search
      gcl.filter @

    @searchAdvanced = (reset, e) =>
      e.preventDefault()
      #_(@searches).keys().each (field) =>
      _.each(_.keys(@searches), (field) =>
        unless reset
          if @searches[field]().length is 0
            delete @activeFilters[field] if @activeFilters[field]
          else
            value = @searches[field]().toLowerCase()
            @activeFilters[field] = (item) ->
              item[field].toLowerCase().indexOf(value) isnt -1
        else
          @searches[field]('')
          delete @activeFilters[field]
        gcl.filter @
      )

    @csvExport = =>
      items = @filteredItems or @items
      schema =
        code: l.CODE
        label: l.LABEL
        monitor: l.MONITOR
        timeSlot: l.TIMESLOT
        places: l.PLACES
        note: l.NOTE
      gcl.csvExport items, schema, 'activites'


    callback = (err, results) =>
      if err
        golem.widgets.common.notifications.errorUnexpected body: err
        @items = []
        m.endComputation()
      else
        @items = results.rows.map (r) -> new golem.Activity r.doc
        golem.model.getMembersFromActivity null, (err, res) =>
          if err
            golem.widgets.common.notifications.errorUnexpected body: err
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
    gwf = golem.widgets.form

    advancedSearchDom = ->
      m 'form',
        class: 'ui small form'
        onsubmit: ctrl.searchAdvanced.bind(ctrl, false),
        [
          m 'fieldset.fields', [
            m 'legend', [
              m 'i', { class: 'icon help' }
              m 'span', l.SEARCH_ADVANCED_HELP
            ]
            gwf.inputHelper
              inputCls: 'five wide column field input'
              name: 'label'
              placeholder: l.LABEL
              minlength: 2
              maxlength: 100
              value: ctrl.searches.label()
              oninput: m.withAttr 'value', ctrl.searches.label
            gwf.inputHelper
              inputCls: 'two wide column field input'
              name: 'code'
              placeholder: l.CODE
              minlength: 2
              maxlength: 30
              value: ctrl.searches.code()
              oninput: m.withAttr 'value', ctrl.searches.code
            gwf.inputHelper
              inputCls: 'four wide column field input'
              name: 'monitor'
              placeholder: l.MONITOR
              minlength: 2
              maxlength: 50
              value: ctrl.searches.monitor()
              oninput: m.withAttr 'value', ctrl.searches.monitor
            m 'div', { class: 'ui buttons' }, [
              m 'input',
                class: 'ui green small submit button'
                type: 'submit'
                value: l.OK
              m 'button',
                name: 'cancel'
                class: 'ui small button'
                type: 'button'
                onclick: ctrl.searchAdvanced.bind(ctrl, true),
                l.CANCEL
            ]
          ]
        ]

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

    gcl = golem.component.list
    mainContent = m 'table', { class: 'ui basic table' }, [
      m 'thead', [
        m 'tr', [
          gcl.sortTableHeaderHelper ctrl: ctrl, field: 'label'
          gcl.sortTableHeaderHelper ctrl: ctrl, field: 'code'
          m 'th', l.TIMESLOT
          m 'th', l.MONITOR
          gcl.sortTableHeaderHelper ctrl: ctrl, field: 'places'
          m 'th', l.PLACES_TAKEN
          m 'th', { width: '10%' }, l.ACTIONS
        ]
      ]
      m 'tbody', (if ctrl.filteredItems then ctrl.filteredItems.map itemDom else ctrl.items.map itemDom)
    ]
    searchBox = golem.component.list.searchBox ctrl.searchGlobal
    contextMenuContent = m 'nav', [
      m 'menu', { class: 'ui small vertical menu' }, [
        searchBox.head
        searchBox.content
      ]
    ]
    return [
      m 'section', { class: 'twelve wide column' }, [
        new golem.menus.secondary.view()
        golem.widgets.common.headerExpandible
          ctrl: ctrl
          activeField: 'searchAdvancedOn'
          title: l.SEARCH_ADVANCED
          cls: 'inverted center aligned black'
        advancedSearchDom() if ctrl.searchAdvancedOn
        m 'h3',
          class: 'ui inverted center aligned purple header',
          [
            m 'span', [
              l.ACTIVITIES_LIST + ' '
              m 'i',
                title: l.CSV_EXPORT
                class: 'text file outline icon'
                style: cursor: 'pointer'
                onclick: ctrl.csvExport
            ]
          ]
        mainContent
      ]
      m 'section', { class: 'four wide column' }, contextMenuContent
    ]
