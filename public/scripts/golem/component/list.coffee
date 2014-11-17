l = golem.config.locale
golem.component.list =
  sort: (e, items) ->
    field = e.target.getAttribute 'data-sort-by'
    if field
      first = items[0]
      items.sort (a, b) ->
        (if a[field] > b[field] then 1 else (if b[field] < a[field] then -1 else 0))
      items.reverse() if first is items[0]

  search: (value, item) ->
    json = JSON.stringify(item).toLowerCase()
    json.indexOf(value.toLowerCase()) isnt -1

  filter: (ctrl) ->
    if _(ctrl.activeFilters).isEmpty()
      ctrl.filteredItems = null
    else
      ctrl.filteredItems = ctrl.items.filter (item) ->
        for fn in _(ctrl.activeFilters).values()
          return false unless fn item
        true

  mailing: (items) ->
    mails = []
    for item in items
      if item.communicationModes.mail
        for mail in item.mails
          if mail.default
            mails.push mail.value
    mails = _.uniq(mails).join(',')
    "mailto:mjcval@gmail.com?bcc=#{mails}"

  csvExport: (items, schema, filename, csv = []) ->
    csv.push [("\"#{locale}\"" for field, locale of schema).join(';')]
    for item in items
      line = ("\"#{item[field]}\"" for field, locale of schema)
      csv.push line.join(';')
    aNode = document.createElement 'a'
    aNode.href = "data:text/csv;charset=utf-8,#{encodeURIComponent csv.join('\r\n')}"
    aNode.target = '_blank'
    aNode.download = "#{filename}.csv"
    document.body.appendChild aNode
    aNode.click()
    document.body.removeChild aNode

  searchBox: (searchFn) ->
    head: m 'div', { class: 'header item' }, [
      m 'span', l.SEARCH_GLOBAL
      m 'i', { class: 'warning icon', title: l.SEARCH_GLOBAL_WARNING }
    ]
    content: m 'div',
      class: 'item', [
        m 'div', class: 'ui small icon input', [
          m 'input',
            type: 'search'
            placeholder: l.TYPE_HERE
            title: l.SEARCH_ERROR_TOO_SHORT
            oninput: searchFn
          m 'i', class: 'unhide icon'
        ]
      ]

  tagsBox: (config, ctrl) ->
    field = config.field or 'tags'
    tags = ctrl[(config.field or 'tags')]
    tagsIconAttrs = class: "#{config.tagsIcon or 'tags'} icon"
    tagsClass = ''
    if ctrl.tagFilter
      tagsIconAttrs =
        class: 'eraser icon'
        title: l.FILTERS_REMOVE
      tagsClass = ' active'
    return { head: m 'div', class: 'header item', l.FILTERS
    groups: m 'a', class: 'item', [
      m 'i', class: 'users icon'
      l.BY_GROUP
    ]
    tags: m 'div', [
      m 'a',
        class: 'item' + tagsClass
        onclick: ctrl.filterByTag.bind(ctrl, null, field),
        [
          m 'i', tagsIconAttrs
          config.label or l.BY_TAG
        ]
      m 'a', tags.map (tag) ->
        items = [
          tag.key[1]
          m 'div',
            class: "ui small #{config.counterCls or 'teal'} label",
            tag.value
        ]
        classTag = 'item'
        classTag += ' active' if ctrl.tagFilter is tag.key[1]
        m 'a',
          class: classTag
          onclick: ctrl.filterByTag.bind(ctrl, tag.key[1], field),
          items
    ] }

  sortTableHeaderHelper: (config) ->
    varName = config.field + 'IconDisplay'
    config.ctrl[varName] ?= 'hidden'
    attributes =
      'data-sort-by': config.field
      onmouseover: -> config.ctrl[varName] = 'visible'
      onmouseout: -> config.ctrl[varName] = 'hidden'
      onclick: config.ctrl.sort
      style: { cursor: 'pointer' }
    title = config.title or config.field.toUpperCase()
    content = [
      m 'span', attributes, golem.config.locale[title]
      m 'i',
        class: 'icon sort'
        style: { visibility: config.ctrl[varName], marginLeft: '3px' }
    ]
    m 'th', { 'data-sort-by': config.field }, content

