## Notification system

Homemade notification system. It proposes boxes with different styles and
optionally a close timeout. The list of active notifications is handled by the
namespace, on `items` as a reactive array.

    n = items: rx.array()

### Classic Notification


A `notification` is an object that can be created through a `props` JS object.
This one can have :

- a `title`, required;
- a `content`, recommended, that can be a bunch of HTML;
- an `icon` class, according to Semantic and Font Awesome;
- a `timeout`, in seconds, by default 10. It can be `false` for avoiding
  automatic close.
- optional `displayCb`, `closeCb` and `clickFn` functions callbacks that will
  be called respectively when the notification is displayed,closed and when the
  user clicks on the notification elsewhere the close icon (clickFn by default
  closes the notification).

Then the notification is automatically sent.

    n.notification = (me) ->
      me.timeout ?= 10
      me

#### Sending

`send` is the most basic and powerfull way of sending a notification to the
user. It takes a notification as required parameter.

    n.send = (notification) ->
      n.items.push notification
      notification.displayCb() if notification.displayCb

### Predefined Notifications

A successfull `notification` already provides a title, a class and an icon. It
just needs the `content` and an optional `timeout`.

    n.success = (me) ->
      _.extend me, title: L('SUCCESS'), cls: 'success', icon: 'checkmark'
      n.notification me

An `info` `notification` only fixes the `cls` and `icon` and takes an optional
`title` (default to locale INFO) and a required `content`.

    n.info = (me) ->
      me.title ?= L 'INFO'
      me.cls = me.icon = 'info'
      n.notification me

A `warning` `notification` lets only gives the `content`. `title`, `cls` and
`icon` are fixed. `timeout` is by default set to 15 seconds.

    n.warning = (me) ->
      me.title = L 'WARNING'
      me.cls = me.icon = 'warning'
      me.timeout ?= 15
      n.notification me

As `warning`, an `error` `notification` just needs a `content` or a function.
The `timeout` is fixed to `false`.

    n.error = (props) ->
      me =
        title: L 'ERROR'
        cls: 'error'
        icon: 'attention'
        timeout: false
      me = _.extend props, me
      n.notification me

`unexpected` is an `error` `notification` with partially defined `content`.

    n.unexpected = (me) ->
      me.content = "<em>#{me.content}</em><br/>#{L 'ERROR_UNEXPECTED'}"
      n.error me

### Notification Template

`close` function is used when the user clicked on the close icon or on the
`notification` if no `click` function has been provided. It removes the
`notification` from the reactive array and clears the timeout.

    close = (notif, from) ->
      window.clearTimeout(notif.timeoutId) if notif.from isnt 'timeout'
      n.items.remove notif
      notif.closeCb() if notif.closeCb


`delayClose` is called after each drawning into the DOM : if the `timeout`
isn't `false` then the `notification` will be automatically closed after by
default 10 seconds.

    delayClose = (notif) ->
      if notif.timeout
        notif.timeoutId = window.setTimeout ->
          close(notif, 'timeout')
        , notif.timeout * 1000

`nClass` takes a notification and returns the string class to use with the
wrapping div element.

     nClass = (notif) ->
        cls = ['ui', 'floating', 'message', 'notification']
        cls.push notif.cls if notif.cls
        cls.push 'icon' if notif.icon
        cls.join ' '

The reactive DOM that iterates over the reactive array.

    n.notifications =
      [
        div n.items.map (notif) ->
            delayClose notif
            div
              class: nClass notif
              click: notif.clickFn or _.partial(close, notif)
            , [
              if notif.icon then i { class: notif.icon + ' icon' } else ''
              i
                class: 'close icon'
                click: _.partial(close, notif)
              div { class: 'content' }, [
                div { class: 'header' }, notif.title
                div $.parseHTML("<p>#{notif.content}</p>")
              ]
            ]
      ]

## Public API

    golem.common.notification = n
