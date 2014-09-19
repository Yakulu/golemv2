# GOLEM

Main module for GOLEM. It's intended to bootstrap the application.

## Resident components

There are global to GOLEM but text can change, according to the application's
configuration and localization : `$header` and `$footer`.

    $header =  header [
      h1 { class: 'ui inverted black block small header center aligned' },
      bind -> "#{L 'TITLE'} : #{L 'HEADER'}"
    ]

    $footer = footer [
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

Outside of first globals import into `index.html`, here is the first function
to be called into this app. `init`, after the initial DOM readyness, takes the
most important part of the layout and populates them.

    init = ->
      g = golem
      $ ->
        g.roots =
          $main: $ '#golem-main'
        $('#golem-header').append $header
        $('#golem-mainmenu').append g.menus.main
        $('#golem-footer').append $footer
        $('#golem-notification').append g.widgets.common.notification.Template
        g.roots.$main.append g.auth()

The `initRouting` part is executed only is authentification is valid (TMP
FIXME, of course). This function is here to put the router in place and
launches it.

    golem.initRouting = ->
      replaceMain = (dom) -> golem.roots.$main.children().replaceWith dom
      router = new LightRouter
        routes:
          '': -> replaceMain golem.home()
          'auth': -> replaceMain golem.auth()
      router.run()

    init()
