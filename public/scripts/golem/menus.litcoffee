# Menus

GOLEM is composed of two menus : a main one and a secondary.

## MenuItem

Each menu shares the same `menuitem` creation function. A `title`, an `URL` and
the Semantic CSS `icon` class name are mandatory. The `url` will be keeped as
`baseUrl`. An optional `cls` can be fixed, by default to 'item'.

    menuitem = (title, url, icon, cls = 'item') ->
      title: title
      url: url
      baseUrl: url
      icon: icon
      cls: cls

The defaults `MenuItems`.
      
    mainMenusItems = rx.array [
      menuitem L('HOME'), '/home', 'home'
      menuitem L('CONTACTS'), '/contact', 'book', 'item disabled'
      #menuitem L('FAMILIES'), '/family', 'sitemap'
      menuitem L('MEMBERS'), '/member', 'user'
      menuitem L('MESSAGES'), '/mail', 'mail', 'item disabled'
      menuitem L('ACTIVITIES'), '/activity', 'globe'
      menuitem L('STATISTICS'), '/stats', 'pie chart basic', 'item disabled'
      menuitem L('ADMINISTRATION'), '/admin', 'wrench', 'item disabled'
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

    menuItemView = (activeType, item) ->
      active = _active(_isActive(activeType, golem.activeUrl.get(), item.url))
      a { class: "#{item.cls}#{active}", href: "##{item.url}" }, [
        i { class: "#{item.icon} icon" }
        item.title
      ]

The template for the `mainMenu` formats each `MenuItem` into a <menu> box.
It's reactive, so it can be changed at runtime without much effort. Its marked
as active if the URL contains the `item.url`.

    mainMenu = nav bind -> [
      menu {
        id: 'main-menu'
        class: 'ui vertical labeled icon menu'
      }, mainMenusItems.map menuItemView.bind(null, 'contains')
    ]

The same thing happens to the `secondaryMenu`, with different classes. It's
maked as active only if the `item.url` is exactly the `activeUrl`.

    secondaryItems = rx.array()
    secondaryMenu = nav [
      menu
        class: 'ui small secondary pointing menu',
        secondaryItems.map menuItemView.bind(null, 'is')
    ]

## Public API

    golem.menus =
      menuitem: menuitem
      mainItems: mainMenusItems
      main: mainMenu
      secondaryItems: secondaryItems
      secondary: secondaryMenu
