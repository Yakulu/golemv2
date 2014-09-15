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

  searchBox: (searchFn) ->
    head: m 'div',
      class: 'header item',
      l.SEARCH_GLOBAL
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

  tagsBox: (tags, ctrl) ->
    tagsIconAttrs = class: 'tags icon'
    tagsClass = ''
    if ctrl.tagFilter
      tagsIconAttrs =
        class: 'eraser icon'
        title: l.FILTERS_REMOVE
      tagsClass = ' active'
    head: m 'div', class: 'header item', l.FILTERS
    groups: m 'a', class: 'item', [
      m 'i', class: 'users icon'
      l.BY_GROUPS
    ]
    tags: m 'div', [
      m 'a',
        class: 'item' + tagsClass
        onclick: ctrl.filterByTag.bind(ctrl, null),
        [
          m 'i', tagsIconAttrs
          l.BY_TAGS
        ]
      m 'a', tags.map (tag) ->
        items = [
          tag.key[1]
          m 'div',
            class: 'ui small teal label',
            tag.value
        ]
        classTag = 'item'
        classTag += ' active' if ctrl.tagFilter is tag.key[1]
        m 'a',
          class: classTag
          onclick: ctrl.filterByTag.bind(ctrl, tag.key[1]),
          items
    ]

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

