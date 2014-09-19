# Widgets - common


These widgets can be used everywhere in the GOLEM application.

## Header expandable

The `headerExpandable` is a widget that is intended to show a header that can
be opened and closed with an icon. It just toggles a boolean, wich will be used
to toggle the whole content. `headerExpandable` take a `config` object as
argument with a `title`, a `class` and the boolean `active`. All are required.

    headerExpandable = (c) ->
      toggleActive = -> c.active.set(not c.active.get())
      h3 { class: "ui header #{c.class}" }, [
        span [
          c.title + ' '
          i
            class: if c.active.get() then 'icon collapse' else 'icon expand'
            style: { cursor: 'pointer' }
            click: toggleActive
        ]
      ]

## Modal

    modal = ->

## Notification system

Homemade notification system. It proposes boxes with different styles and
optionally a close timeout. The list of active Notifications is handled by the
namespace, as a reactive array.

    n = items: rx.array()

### Classic Notification


A `Notification` is an object that can be created through a `props` JS object.
This one can have :

* a `title`, required;
* a `content`, recommended, that can be a bunch of HTML;
* an `icon` class, according to Semantic and Font Awesome;
* a `timeout`, in seconds, by default 10. It can be `false` for avoiding
automatic close;
* an optional `click` function, when the Notification is clicked, default to
close.

    class n.Notification
      constructor: (props, callback) ->
        {@title, @content, @icon, @cls, @timeout, @click} = props
        @timeout ?= 10

#### Sending

`send` is the most basic and powerfull way of sending a notification to the
user. It takes an optional callback function as argument.

      send: (callback) ->
        n.items.push @
        callback if callback?

### Predefined Notifications

A successfull `Notification` already provides a title, a class and an icon. It
just needs the `content` and an optional `timeout`.

    class n.Success extends n.Notification
      constructor: ({ content, timeout }, callback) ->
        props =
          title: L 'SUCCESS'
          cls: 'success'
          icon: 'checkmark'
          content: content
          timeout: timeout
        super props, callback

An `Error` `Notification` just needs a `content`. Even the `timeout` is fixed
to `false`.

    class n.Error extends n.Notification
      constructor: ({ content }, callback) ->
        props =
          title: L 'ERROR'
          cls: 'error'
          icon: 'attention'
          timeout: false
          content: content
        super props, callback

### Notification Template

The reactive DOM that iterates over the reactive array.

`delayClose` is called after each drawning into the DOM : if the `timeout`
isn't `false` then the `Notification` will be automatically closed after by
default 10 seconds.

`close` function is used when the user clicked on the close icon or on the
`Notification` if no `click` function has been provided. It removes the
`Notification` from the reactive array and clears the timeout.

    n.Template = do ->
      close = (notif, from) ->
        window.clearTimeout(notif.timeoutId) if notif.from isnt 'timeout'
        n.items.remove notif

      delayClose = (notif) ->
        if notif.timeout
          timeoutId = window.setTimeout ->
            close(notif, 'timeout')
          , notif.timeout * 1000
          notif.timeoutId = timeoutId
      [
        div n.items.map (notif) ->
            delayClose notif
            nCls = ['ui', 'floating', 'message', 'notification']
            nCls.push notif.cls if notif.cls
            nCls.push 'icon' if notif.icon
            div
              class: nCls.join ' '
              click: if notif.click then notif.click else close.bind(null, notif)
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

    golem.widgets =
      common:
        headerExpandable: headerExpandable
        modal: modal
        notification: n
