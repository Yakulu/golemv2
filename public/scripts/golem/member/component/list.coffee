module = golem.module.member
module.component.list =
  controller: ->
    window.ctrl = @
    l = golem.config.locale
    mi = module.data.menuItems
    gcl = golem.component.list
    golem.menus.secondary.items = [mi.list, mi.add, mi.tags, mi.skills]
    document.title = golem.utils.title l.MEMBERS_LIST
    @sort = (e) => golem.component.list.sort e, @items
    @searchGlobal = (e) =>
      value = e.target.value
      if value.length > 3
        @activeFilters.search = gcl.search.bind null, value
      else
        delete @activeFilters.search
      gcl.filter @

    
    @searchAdd = => @searches.push field: null, value: ''
    @searchRemove = (idx) =>
      s = (@searches.splice idx, 1)[0]
      if @activeFilters[s.field]
        delete @activeFilters[s.field]
        gcl.filter @
    @searchSelect = (idx, e) =>
      oldField = @searches[idx].field
      delete @activeFilters[oldField] if @activeFilters[oldField]
      @searches[idx].field = e.target.value
    @searchValue = (idx, value) => @searches[idx].value = value

    @searchAdvanced = (reset, e) =>
      e.preventDefault()
      @searches.forEach (s) =>
        switch s.field
          when 'lastname', 'firstname', 'nationality', 'profession'
          , 'postalCode', 'city', 'number'
            value = s.value.toLowerCase()
            @activeFilters[s.field] = (item) ->
              item[s.field]?.toLowerCase().indexOf(value) isnt -1
          when 'fullname', 'fulladdress', 'fullguardian'
            value = s.value.toLowerCase()
            @activeFilters[s.field] = (item) ->
              item[s.field]?().toLowerCase().indexOf(value) isnt -1
          when 'tels', 'mails'
            value = s.value.toLowerCase()
            @activeFilters[s.field] = (item) ->
              for f in item[s.field]
                return true if f.value.toLowerCase().indexOf(value) isnt -1
              false
      gcl.filter @


    @filterByTag = (tag, field) =>
      if tag
        @tagFilter = tag
        @activeFilters.tags = (member) ->
          member[field] and tag in member[field]
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

    callback = (err, results) =>
      if err
        golem.widgets.common.notifications.errorUnexpected body: err
        @items = []
      else
        @items = results.rows.map (r) -> new golem.Member r.doc
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
      module.data.getSkills =>
        @skills = module.data.skills[0..4]
        golem.model.getBySchema 'member', callback
    return

  view: (ctrl) ->
    l = golem.config.locale
    form = golem.widgets.form


    searchExtraFields = (s, idx) ->
      switch s.field
        when 'number', 'lastname', 'firstname', 'fullname', 'nationality'
        , 'profession', 'fulladdress', 'postalCode', 'city', 'tels', 'mails'
        , 'fullguardian'
          m 'input',
            class: 'six wide field input'
            name: s.field
            type: 'text'
            required: true
            placeholder: l.TYPE_HERE
            value: s.value
            oninput: m.withAttr 'value', ctrl.searchValue.bind(ctrl, idx)
        else '' # TODO: gender, birthday, communicationModes, authorizations

    advancedSearchDom = ->
      m 'form',
        class: 'ui small form'
        onsubmit: ctrl.searchAdvanced.bind(ctrl, false),
        [
          m 'fieldset.fields', [
            m 'legend', l.FILTERS
            m 'div', { class: 'ui buttons' }, [
              form.addButton ctrl.searchAdd, l.NEW
              m 'input',
                class: 'ui green tiny submit button'
                type: 'submit'
                value: l.SEARCH
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
                      m 'option', value: 'number', l.MEMBER_NUMBER
                      m 'option', value: 'lastname', l.LASTNAME
                      m 'option', value: 'firstname', l.FIRSTNAME
                      m 'option', value: 'fullname', l.FULLNAME
                      m 'option', value: 'gender', l.GENDER
                      m 'option', value: 'birthday', l.BIRTHDAY
                      m 'option', value: 'nationality', l.NATIONALITY
                      m 'option', value: 'profession', l.PROFESSION
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
                    m 'optgroup', label: l.MINOR, [
                      m 'option', value: 'fullguardian', l.CHILD_GUARDIAN
                      m 'option', value: 'authorizations', l.AUTHORIZATIONS
                    ]
                  ]
                searchExtraFields s, idx
                m 'button', # Remove button
                  class: 'ui small red icon button'
                  title: l.DELETE
                  onclick: -> ctrl.searchRemove idx
                , [ m 'i', { class: 'remove sign icon' } ]
              ]
          ]
        ]

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
    tagsBox = golem.component.list.tagsBox { tags: ctrl.tags }, ctrl
    skillsBox = golem.component.list.tagsBox
      field: 'skills'
      label: l.BY_SKILL
      tagsIcon: 'briefcase'
      counterCls: 'blue',
      ctrl
    contextMenuContent = m 'section', { class: 'four wide column' },
      m 'nav', [
        m 'menu', { class: 'ui small vertical menu' }, [
          tagsBox.head
          tagsBox.tags
          skillsBox.tags
        ]
      ]
    listHeaderDom = do ->
      titleDom = [ l.MEMBERS_LIST + ' ' ]
      unless _(ctrl.activeFilters).isEmpty()
        titleDom.push m 'i'
      m 'h3',
        class: 'ui inverted center aligned purple header',
        [ m 'span', titleDom ]

    eraserVisibility = do ->
      if _(ctrl.activeFilters).isEmpty() then 'hidden' else 'visible'

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
              l.MEMBERS_LIST + ' '
              m 'i',
                title: l.FILTERS_REMOVE
                class: 'icon eraser'
                style:
                  cursor: 'pointer'
                  visibility: eraserVisibility
                onclick: ctrl.filtersRemoveAll
          ]
        ]
        mainContent
      ]
      m 'section', { class: 'four wide column' }, contextMenuContent
    ]
