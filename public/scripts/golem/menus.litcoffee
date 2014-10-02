# Menus

GOLEM is composed of two menus : a main one and a secondary.

    menus = {}

## MenuItem

Each menu shares the same `menuitem` creation function. A `title`, an `URL` and
the Semantic CSS `icon` class name are mandatory. The `url` will be keeped as
`baseUrl`. An optional `cls` can be fixed, by default to 'item'.

    menus.item = (title, url, icon, cls = 'item') ->
      title: title
      url: url
      baseUrl: url
      icon: icon
      cls: cls

The defaults `MenuItems`.
      
    menus.mainItems = rx.array [
      menus.item L('HOME'), '/home', 'home'
      menus.item L('CONTACTS'), '/contact', 'book', 'item disabled'
      #menuitem L('FAMILIES'), '/family', 'sitemap'
      menus.item L('MEMBERS'), '/member', 'user'
      menus.item L('MESSAGES'), '/mail', 'mail', 'item disabled'
      menus.item L('ACTIVITIES'), '/activity', 'globe'
      menus.item L('STATISTICS'), '/stats', 'pie chart basic', 'item disabled'
      menus.item L('ADMINISTRATION'), '/admin', 'wrench', 'item disabled'
    ]

## Menus templates

Each `menuitem` is represented as a link which can be active according to the
URL. If the active hash contains or is exactly the item url, this one will be
marked as active. `isActive` is the function that checks the activity whereas
`activeClass` is the one that returns the string class.

    _isActive = (type, activeUrl, itemUrl) ->
      if type is 'contains'
        activeUrl.indexOf(itemUrl) isnt -1
      else # is
        itemUrl is activeUrl

    _active = (bool) -> if bool then ' active' else ''

    _menuItemView = (activeType, item) ->
      active = _active(_isActive(activeType, golem.activeUrl.get(), item.url))
      a { class: "#{item.cls}#{active}", href: "##{item.url}" }, [
        i { class: "#{item.icon} icon" }
        item.title
      ]

The template for the `main` formats each `MenuItem` into a <menu> box.  It's
reactive, so it can be changed at runtime without much effort. Its marked as
active if the URL contains the `item.url`.

    menus.main= nav bind -> [
      menu {
        id: 'main-menu'
        class: 'ui vertical labeled icon menu'
      }, menus.mainItems.map _menuItemView.bind(null, 'contains')
    ]

The same thing happens to the `secondaryMenu`, with different classes. It's
maked as active only if the `item.url` is exactly the `activeUrl`.

    menus.secondaryItems = rx.array()
    menus.secondary = nav [
      menu
        class: 'ui small secondary pointing menu',
        menus.secondaryItems.map _menuItemView.bind(null, 'is')
    ]

## Public API

    golem.menus = menus
