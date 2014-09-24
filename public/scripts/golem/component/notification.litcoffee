## Notification system

Homemade notification system. It proposes boxes with different styles and
optionally a close timeout. The list of active Notifications is handled by the
namespace, as a reactive array.

    n = items: rx.array()

### Classic Notification


A `Notification` is an object that can be created through a `props` JS object.
This one can have :

- a `title`, required;
- a `content`, recommended, that can be a bunch of HTML;
- an `icon` class, according to Semantic and Font Awesome;
- a `timeout`, in seconds, by default 10. It can be `false` for avoiding
  automatic close.

    class n.Notification
      constructor: (props) ->
        {@title, @content, @icon, @cls, @timeout} = props
        @timeout ?= 10

#### Sending

`send` is the most basic and powerfull way of sending a notification to the
user. It takes an optional properties object with `displayCb` and `closeCb`
functions callbacks and another optional `clickFn` function that will be called
when the user clicks on the notifications elsewhere the close icon (defaults
close the `Notification`).

      send: ({displayCb, @closeCb, @clickFn} = {}) ->
        n.items.push @
        displayCb() if displayCb

### Predefined Notifications

A successfull `Notification` already provides a title, a class and an icon. It
just needs the `content` and an optional `timeout`.

    class n.Success extends n.Notification
      constructor: (props) ->
        props.title = L 'SUCCESS'
        props.cls = 'success'
        props.icon = 'checkmark'
        super props

An `Info` `Notification` only fixes the `cls` and `icon` and takes an optional
`title` (default to `l.INFO`) and a required `content`.

    class n.Info extends n.Notification
      constructor: (props) ->
        props.title ?= L 'INFO'
        props.cls = props.icon = 'info'
        super props

A `Warning` `Notification` lets only gives the `content`. `title`, `cls` and
`icon` are fixed. `timeout` is by default set to 15 seconds.

    class n.Warning extends n.Notification
      constructor: (props) ->
        props.title = L 'WARNING'
        props.cls = props.icon = 'warning'
        props.timeout ?= 15
        super props

As `Warning`, an `Error` `Notification` just needs a `content` or a function.
The `timeout` is fixed to `false`.

    class n.Error extends n.Notification
      constructor: ({ content }) ->
        props =
          title: L 'ERROR'
          cls: 'error'
          icon: 'attention'
          timeout: false
          content: content
        super props

`Unexpected` is an `Error` `Notification` with partially defined `content`.

    class n.Unexpected extends n.Error
      constructor: (props) ->
        props.content = "<em>#{props.content}</em><br/>#{L 'ERROR_UNEXPECTED'}"
        super props

### Notification Template

The reactive DOM that iterates over the reactive array.

`delayClose` is called after each drawning into the DOM : if the `timeout`
isn't `false` then the `Notification` will be automatically closed after by
default 10 seconds.

`close` function is used when the user clicked on the close icon or on the
`Notification` if no `click` function has been provided. It removes the
`Notification` from the reactive array and clears the timeout.

    n.notifications = do ->
      close = (notif, from) ->
        window.clearTimeout(notif.timeoutId) if notif.from isnt 'timeout'
        n.items.remove notif
        notif.closeCb() if notif.closeCb

      delayClose = (notif) ->
        if notif.timeout
          notif.timeoutId = window.setTimeout ->
            close(notif, 'timeout')
          , notif.timeout * 1000
      [
        div n.items.map (notif) ->
            delayClose notif
            nCls = ['ui', 'floating', 'message', 'notification']
            nCls.push notif.cls if notif.cls
            nCls.push 'icon' if notif.icon
            div
              class: nCls.join ' '
              click: notif.clickFn or close.bind(null, notif)
            , [
              if notif.icon then i { class: notif.icon + ' icon' } else ''
              i
                class: 'close icon'
                click: close.bind(null, notif)
              div { class: 'content' }, [
                div { class: 'header' }, notif.title
                div $.parseHTML("<p>#{notif.content}</p>")
              ]
            ]
      ]

## Public API

    golem.component.notification = n
