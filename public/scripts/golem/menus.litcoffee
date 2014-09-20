# Menus

GOLEM is composed of two menus : a main one and a secondary.

## MenuItem

Each menu shares the same `MenuItem` class.
A `title`, an `URL` and the Semantic CSS `icon` class name are mandatory.
An optional `cls` can be fixed, by default to 'item'.

    class MenuItem
      constructor: (@title, @url, @icon, @cls = 'item') ->

The defaults `MenuItems`.
      
    mainMenusItems = rx.array [
      new MenuItem L('HOME'), '/home', 'home'
      new MenuItem L('CONTACTS'), '/contact/list', 'book', 'item disabled'
      #new MenuItem L('FAMILIES'), '/family', 'sitemap'
      new MenuItem L('MEMBERS'), '/member/list', 'user'
      new MenuItem L('MESSAGES'), '/mail/list', 'mail', 'item disabled'
      new MenuItem L('ACTIVITIES'), '/activity/list', 'globe'
      new MenuItem L('STATISTICS'), '/stats', 'pie chart basic', 'item disabled'
      new MenuItem L('ADMINISTRATION'), '/admin', 'wrench', 'item disabled'
    ]

## Menus templates

Each `MenuItem` is represented as a link which can be active according to the
URL.

    $menuItem = (item) ->
      active = bind ->
        if item.url is golem.router.getUrl() then 'active' else ''
      a { class: "#{item.cls}#{active.get()}", href: "##{item.url}" }, [
        i { class: "#{item.icon} icon" }
        item.title
      ]

The template for the `$mainMenu` formats each `MenuItem` into a <menu> box. It's
reactive, so it can be changed at runtime without much effort.

    $mainMenu = nav [
      menu {
        id: 'main-menu'
        class: 'ui vertical labeled icon menu'
      }, mainMenusItems.map $menuItem
    ]

The same thing happens to the `$secondaryMenu`, whith different classes.

    secondaryItems = rx.array()
    $secondaryMenu = ->
      items: []
      view: ->
      nav [
        menu
          class: 'ui small secondary pointing menu',
          secondaryItems.map $menuItem
      ]

## Public API

    golem.menus =
      Menu: MenuItem
      mainItems: mainMenusItems
      $main: $mainMenu
      secondaryItems: secondaryItems
      $secondary: $secondaryMenu
