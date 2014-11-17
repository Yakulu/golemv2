module = golem.module.contact
module.component.list =
  controller: ->
    l = golem.config.locale
    mi = module.data.menuItems
    gcl = golem.component.list
    gwf = golem.widgets.form
    golem.menus.secondary.items = [mi.list, mi.add, mi.tags]
    document.title = golem.utils.title l.CONTACTS_LIST
    @sort = (e) => golem.component.list.sort e, @items
    @searchGlobal = (e) =>
      value = e.target.value
      if value.length > 3
        @activeFilters.search = gcl.search.bind null, value
      else
        delete @activeFilters.search
      gcl.filter @

    
    @searchHelp = new gwf.helpButton.controller l.HELP, l.SEARCH_ADVANCED_EXTENDED_HELP
    @searchCounter = 0
    @searchAdd = =>
      @searchCounter += 1
      @searches.push field: null, value: ''
    @searchRemove = (idx) =>
      s = (@searches.splice idx, 1)[0]
      if @activeFilters[s.name]
        delete @activeFilters[s.name]
        gcl.filter @
    @searchSelect = (idx, e) =>
      s = @searches[idx]
      delete @activeFilters[s.name] if @activeFilters[s.name]
      s.field = e.target.value
      s.name = "#{e.target.value}-#{@searchCounter}"
    @searchBirthdaySelect = (idx, value) =>
      @searches[idx].constraint = value
    @searchValue = (idx, value) => @searches[idx].value = value

    @searchAdvanced = (reset, e) =>
      e.preventDefault()
      @searches.forEach (s, idx) =>
        switch s.field
          when 'lastname', 'firstname', 'postalCode', 'city'
            value = s.value.toLowerCase()
            @activeFilters[s.name] = (item) ->
              return false unless item[s.field]
              item[s.field].toLowerCase().indexOf(value) isnt -1
          when 'fullname', 'fulladdress'
            value = s.value.toLowerCase()
            @activeFilters[s.name] = (item) ->
              item[s.field]?().toLowerCase().indexOf(value) isnt -1
          when 'tels', 'mails'
            value = s.value.toLowerCase()
            @activeFilters[s.name] = (item) ->
              for f in item[s.field]
                return true if f.value.toLowerCase().indexOf(value) isnt -1
              false
          when 'communicationModes'
            @activeFilters[s.name] = (item) -> item[s.field][s.value]

      gcl.filter @


    @filterByTag = (tag, field) =>
      if tag
        @tagFilter = tag
        @activeFilters.tags = (contact) ->
          contact[field] and tag in contact[field]
      else
        @tagFilter = null
        delete @activeFilters.tags
      gcl.filter @

    @filtersRemoveAll = =>
      @searches = []
      @activeFilters = {}
      @tagFilter = null
      @searchAdvancedOn = false
      gcl.filter @

    @csvExport = =>
      _items = @filteredItems or @items
      items = (_.clone item for item in _items)
      schema =
        lastname: l.LASTNAME
        firstname: l.FIRSTNAME
        address: l.ADDRESS
        postalCode: l.POSTAL_CODE
        city: l.CITY
        mails: l.MAILS
        tels: l.TELS
        communicationModes: l.COMMUNICATION_MODES
        tags: l.TAGS
      for item in items
        item.guardian = "#{item.guardianLastname} #{item.guardianFirstname}" if item.guardianLastname
        for field, locale of schema
          switch field
            when 'tels', 'mails'
              values = ("#{v.label}: #{v.value}" for v in item[field])
              item[field] = values.join ','
            when 'communicationModes'
              keys = []
              for k, v of item[field]
                if v then keys.push k
              item[field] = keys.join ','
            else
              item[field] ?= ''
      gcl.csvExport items, schema, 'contacts'

    callback = (err, results) =>
      if err
        golem.widgets.common.notifications.errorUnexpected body: err
        @items = []
      else
        @items = results.rows.map (r) -> new golem.Contact r.doc
      m.endComputation()

    # Init
    @items = []
    @filteredItems = null
    @activeFilters = {}
    @searchAdvancedOn = false
    @searches = [] # Arrays of objects representing search form

    m.startComputation()
    module.data.getTags =>
      @tags = module.data.tags[0..4] # Only the first five tags for listing, thx
      golem.model.getBySchema 'contact', callback
    return

  view: (ctrl) ->
    l = golem.config.locale
    form = golem.widgets.form


    searchExtraFields = (s, idx) ->
      switch s.field
        when 'lastname', 'firstname', 'fullname', 'fulladdress', 'postalCode'
        , 'city', 'tels', 'mails'
          [
            m 'input',
              class: 'six wide field input'
              name: "#{s.field}-#{idx}"
              type: 'text'
              required: true
              placeholder: l.TYPE_HERE
              value: s.value
              oninput: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
          ]
        when 'communicationModes'
          [
            m 'div', { class: 'ui radio checkbox' }, [
              m 'input',
                type: 'radio'
                id: "#{s.field}-#{idx}-mail"
                name: "#{s.field}-#{idx}"
                checked: s.value is 'mail'
                value: 'mail'
                onchange: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
              m 'label', { for: "#{s.field}-#{idx}-mail" }, l.MAIL
            ]
            m 'div', { class: 'ui radio checkbox' }, [
              m 'input',
                type: 'radio'
                id: "#{s.field}-#{idx}-tel"
                name: "#{s.field}-#{idx}"
                checked: s.value is 'tel'
                value: 'tel'
                onchange: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
              m 'label', { for: "#{s.field}-#{idx}-tel" }, l.TEL
            ]
          ]
        else []

    advancedSearchDom = ->
      m 'form',
        class: 'ui small form'
        onsubmit: ctrl.searchAdvanced.bind(ctrl, false),
        [
          m 'fieldset.fields', [
            m 'legend', l.FILTERS
            m 'div', { class: 'ui buttons' }, [
              new golem.widgets.form.helpButton.view ctrl.searchHelp
              form.addButton ctrl.searchAdd, l.NEW
            ]
            ctrl.searches.map (s, idx) ->
              m 'div', { class: 'fields' }, [
                m 'select',
                  onchange: ctrl.searchSelect.bind(ctrl, idx)
                  value: s.field
                  class: 'five wide field'
                  required: true
                  'data-idx': idx
                  name: "search-adv-#{idx}", [
                    m 'option', { value: '', hidden: true }
                    m 'optgroup', label: l.CIVILITY, [
                      m 'option', value: 'lastname', l.LASTNAME
                      m 'option', value: 'firstname', l.FIRSTNAME
                      m 'option', value: 'fullname', l.FULLNAME
                    ]
                    m 'optgroup', label: l.CONTACT_DETAILS, [
                      m 'option', value: 'fulladdress', l.FULLADDRESS
                      m 'option', value: 'postalCode', l.POSTAL_CODE
                      m 'option', value: 'city', l.CITY
                      m 'option', value: 'tels', l.TEL
                      m 'option', value: 'mails', l.MAIL
                      m 'option',
                        value: 'communicationModes',
                        l.COMMUNICATION_MODES
                    ]
                  ]
                searchExtraFields(s, idx).map (xfield) -> xfield
                m 'button', # Remove button
                  type: 'button'
                  class: 'ui small red icon button'
                  title: l.DELETE
                  onclick: (e) -> ctrl.searchRemove idx
                , [ m 'i', { class: 'remove sign icon' } ]
              ]
            m 'p', [
              m 'input',
                class: 'ui teal tiny submit button'
                type: 'submit'
                value: l.SEARCH
            ]
          ]
        ]

    itemDom = (f) ->
      m 'tr', [
        m 'td', f.number
        m 'td', f.fullname()
        m 'td', f.fulladdress()
        m 'td', f.tels.forEach (t) ->
          if t.default
            t.value.match(/\d{2}/g).join '.'
        m 'td', f.mails.map (mail) ->
          if mail.default
            m 'a', { href: 'mailto:' + mail.value }, mail.value
        m 'td.actions', [
          m 'a',
            href: '#/contact/show/' + f._id
            title: l.VIEW,
            [m 'i', { class: 'unhide icon' }]
          m 'a',
            href: '#/contact/edit/' + f._id
            title: l.EDIT,
            [m 'i', { class: 'edit icon' }]
          m 'a',
            href: '#/contact/remove/' + f._id
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
            gcl.sortTableHeaderHelper ctrl: ctrl, field: 'lastname'
            gcl.sortTableHeaderHelper
              ctrl: ctrl
              field: 'city'
              title: 'ADDRESS'
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
    tagsBox = golem.component.list.tagsBox { tags: ctrl.tags }, ctrl
    contextMenuContent = m 'section', { class: 'four wide column' },
      m 'nav', [
        m 'menu', { class: 'ui small vertical menu' }, [
          tagsBox.head
          tagsBox.tags
        ]
      ]
    listHeaderDom = do ->
      titleDom = [ l.CONTACTS_LIST + ' ' ]
      unless _(ctrl.activeFilters).isEmpty()
        titleDom.push m 'i'
      m 'h3',
        class: 'ui inverted center aligned purple header',
        [ m 'span', titleDom ]

    eraserVisibility = do ->
      if _(ctrl.activeFilters).isEmpty() then 'hidden' else 'visible'

    return [
      m 'section', { class: 'twelve wide column golem-list' }, [
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
              l.CONTACTS_LIST + ' '
              m 'a',
                title: l.MAILING
                style: display: 'inline'
                href: golem.component.list.mailing items
                [ m 'i', class: 'mail outline icon' ]
              m 'i',
                title: l.CSV_EXPORT
                class: 'text file outline icon'
                style: cursor: 'pointer', display: 'inline'
                onclick: ctrl.csvExport
              m 'i',
                title: l.FILTERS_REMOVE
                class: 'icon eraser'
                style:
                  cursor: 'pointer'
                  visibility: eraserVisibility
                  display: 'inline'
                onclick: ctrl.filtersRemoveAll
          ]
        ]
        mainContent
      ]
      m 'section', { class: 'four wide column' }, contextMenuContent
    ]
