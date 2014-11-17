menus = golem.menus =
  Item: (@title, @baseUrl, @icon, cls) ->
    @cls = cls or 'item'
    @url = @baseUrl

  itemDom: (item) ->
    cls = item.cls
    cls += ' active' if window.location.hash.indexOf(item.url) isnt -1
    # Temp fix for laggy rendering
    #config: m.route
    m 'a', { class: cls, href: '#' + item.url }, [
        m 'i', { class: item.icon + ' icon' }
        item.title
    ]

menus.main =
  model:
    items: do ->
      l = golem.config.locale
      [
        new menus.Item(l.HOME, '/home', 'home')
        new menus.Item(l.CONTACTS, '/contact', 'book')
        #new menus.Item(l.FAMILIES, '/family', 'sitemap'),
        new menus.Item(l.MEMBERS, '/member', 'user')
        new menus.Item(l.MESSAGES, '/mail', 'mail', 'item disabled')
        new menus.Item(l.ACTIVITIES, '/activity', 'globe')
        new menus.Item(l.STATISTICS, '/stats', 'pie chart basic', 'item disabled')
        new menus.Item(l.ADMINISTRATION, '/admin', 'wrench', 'item disabled')
      ]
    addItem: (title, baseUrl, icon, cls) ->
      menus.main.model.items.push new menus.Item(title, baseUrl, icon, cls)

  controller: ->
  view: (ctrl) ->
    m 'nav',
      [
        m 'menu',
          id: 'main-menu', class: 'ui vertical labeled icon menu',
          menus.main.model.items.map menus.itemDom
      ]

menus.secondary =
  items: []
  view: ->
    m 'nav', [
      m 'menu',
      class: 'ui small secondary pointing menu',
      menus.secondary.items.map menus.itemDom
    ]
