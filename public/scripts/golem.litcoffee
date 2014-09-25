# GOLEM

Main module for GOLEM. It's intended to bootstrap the application.

## Resident components

There are global to GOLEM but text can change, according to the application's
configuration and localization : `headerView` and `footerView`.

    headerView = -> header [
      h1 { class: 'ui inverted black block small header center aligned' },
      bind -> "#{L 'TITLE'} : #{L 'HEADER'}"
    ]

    footerView = -> footer [
      div { class: 'ui horizontal icon divider' }, [
        i { class: 'icon html5' }
      ]
      p { class: 'ui horizontal segment center aligned' }, bind -> [
        span "#{L('FOOTER')} ("
        a { href: L('SOURCE_CODE_URL') }, L('SOURCE_CODE')
        span ')'
      ]
    ]

## GOLEM global initialization

Here is the first function to be called into this app. It sets the globals.
 
    window.golem = golem =
      config: {}
      component: {}
      activity:
        component: {}
      member:
        component: {}
    window.bind = bind = rx.bind
    window.rxt = rxt = rx.rxt
    rx.rxt.importTags()
    window.T = T = rx.rxt.tags
    window.L = L = (str) -> golem.config.locale.get str
    g = golem

    g.router = new LightRouter
    g.activeUrl = rx.cell ''

`replaceMain` is the function used to update aggressively the DOM and simulates
a page to page navigation.

    $ ->
      g.roots =
        main: $ '#golem-main'
      #replaceMain = (dom) -> golem.roots.main.children().replaceWith dom
      replaceMain = (dom) -> g.roots.main.empty().append dom

Here we initialize the router and give it exhaustive routes to handle. Most of
them replace the main part of the GOLEM app by new elements.

      g.router = new LightRouter
        type: 'hash'
        routes:
          '': -> window.location.hash = '#/home'
          '/': -> window.location.hash = '#/home'
          '/home': -> replaceMain g.home()
          '/auth': -> replaceMain g.auth()
          '/activity': ->
            replaceMain new g.activity.component.List().view()
          '/activity/add': ->
            new g.activity.component.Form replaceMain
          '/activity/edit/:id': (id) ->
            new g.activity.component.Form replaceMain, id
          '/activity/show/:id': (id) ->
            g.activity.component.show.launch replaceMain, id
          '/activity/remove/:id': (id) ->
            new g.activity.component.Remove id
          '/member': ->
            replaceMain new g.member.component.List().view()
          '/member/add': ->
            new g.member.component.Form replaceMain
          '/member/edit/:id': (id) ->
            new g.member.component.Form replaceMain, id
      #/activity[\/list]?/ -> replaceMain golem.activity.$list()

After the initial DOM readyness, the function takes the most important part of
the layout and populates them.

      $('#golem-header').append headerView()
      $('#golem-mainmenu').append g.menus.main
      $('#golem-footer').append footerView()
      $('#golem-notification').append g.component.notification.notifications
      g.roots.main.append g.auth()


The `initRouting` part is executed only is authentification is valid (TMP
FIXME, of course). This function is here to launch the router and attaches it
to the `onhashchange` event. It also uses a cell to handle current module URL.

    golem.initRouting = ->
      golem.activeUrl.set window.location.hash[1..]
      golem.router.run()
      window.onhashchange = ->
        golem.activeUrl.set window.location.hash[1..]
        golem.router.run()
