# Menus

GOLEM is composed of two menus : a main one and a secondary.

## MenuItem

Each menu shares the same `MenuItem` class. A `title`, an `URL` and the
Semantic CSS `icon` class name are mandatory. The `url` will be keeped as
`baseUrl`. An optional `cls` can be fixed, by default to 'item'.

    class MenuItem
      constructor: (@title, @url, @icon, @cls = 'item') ->
        @baseUrl = @url

The defaults `MenuItems`.
      
    mainMenusItems = rx.array [
      new MenuItem L('HOME'), '/home', 'home'
      new MenuItem L('CONTACTS'), '/contact', 'book', 'item disabled'
      #new MenuItem L('FAMILIES'), '/family', 'sitemap'
      new MenuItem L('MEMBERS'), '/member', 'user'
      new MenuItem L('MESSAGES'), '/mail', 'mail', 'item disabled'
      new MenuItem L('ACTIVITIES'), '/activity', 'globe'
      new MenuItem L('STATISTICS'), '/stats', 'pie chart basic', 'item disabled'
      new MenuItem L('ADMINISTRATION'), '/admin', 'wrench', 'item disabled'
    ]

## Menus templates

Each `MenuItem` is represented as a link which can be active according to the
URL. If the active hash contains or is exactly the item url, this one will be
marked as active.

    $menuItem = (activeType, item) ->
      active = bind =>
        isActive = do =>
          if activeType is 'contains'
            golem.activeUrl.get().indexOf(item.url) isnt -1
          else # is
            item.url is golem.activeUrl.get()
        if isActive then ' active' else ''
      a { class: "#{item.cls}#{active.get()}", href: "##{item.url}" }, [
        i { class: "#{item.icon} icon" }
        item.title
      ]

The template for the `$mainMenu` formats each `MenuItem` into a <menu> box.
It's reactive, so it can be changed at runtime without much effort. Its marked
as active if the URL contains the `item.url`.

    $mainMenu = nav bind -> [
      menu {
        id: 'main-menu'
        class: 'ui vertical labeled icon menu'
      }, mainMenusItems.map $menuItem.bind(null, 'contains')
    ]

The same thing happens to the `$secondaryMenu`, whith different classes. It's
maked as active only if the `item.url` is exactly the `activeUrl`.

    secondaryItems = rx.array()
    $secondaryMenu = nav [
      menu
        class: 'ui small secondary pointing menu',
        secondaryItems.map $menuItem.bind(null, 'is')
    ]

## Public API

    golem.menus =
      Menu: MenuItem
      mainItems: mainMenusItems
      $main: $mainMenu
      secondaryItems: secondaryItems
      $secondary: $secondaryMenu
