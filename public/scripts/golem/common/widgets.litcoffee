# Widgets - common


These components can be used everywhere in the GOLEM application.

    widgets = {}

## Header expandable

The `headerExpandable` is a component that is intended to show a header that
can be opened and closed with an icon. It just toggles a boolean, wich will be
used to toggle the whole content. `headerExpandable` take a `config` object as
argument with a `title`, a `class` and the boolean `active`. All are required.

    widgets.headerExpandable = (c) ->
      toggleActive = -> c.active.set(not c.active.get())
      h3 { class: "ui header #{c.class}" }, [
        span [
          c.title + ' '
          i
            class: bind ->
              if c.active.get() then 'icon collapse' else 'icon expand'
            style: { cursor: 'pointer' }
            click: toggleActive
        ]
      ]

## Modal

`modal` is a component that takes a config object as argument with :

- a `title` string, for the header
- a `content` HTML body
- a `approvedCb` function callback, called if accepted
- a `deniedCb` function callback, invoked if refused

It creates a jQuery element containing the modal and displays the modal before
returning. It uses the modal module helper from SemanticUI.

TODO: make usage of semantic JS optional (15kb min seems much for only that...)

    widgets.modal = (config) ->
      $elt = div { class: 'ui basic modal' }, [
        div { class:'header' }, config.title
        div { class:'content' }, rxt.rawHtml config.content
        div { class:'actions' }, [
          button
            class: 'ui negative button'
            type: 'button'
            L 'CANCEL'
          button
            class: 'ui positive button'
            type: 'button'
            L 'OK'
        ]
      ]
      $elt.modal 'setting',
        closable: false
        onDeny: config.denyCb
        onApprove: config.approveCb
      .modal 'show'

## Help Button

`helpButton` is a component needing a config object :

- a required `title` string
- a required HTML `content`
- an optional `position` for the popup, defaults to `right center`

It creates a jQuery button element on which the popup will be attached, after a
click event. For the popup, it employs the Semantic jQuery popup plugin.
Finally, it returns the created element.

    widgets.helpButton = (config) ->
      config.position ?= 'right center'
      $elt = button { type: 'button', class: 'ui tiny button' }, [
          i { class: 'help icon' }
          L 'HELP'
      ]
      $elt.popup
        title: config.title
        content: config.content
        on: 'click'
        position: config.position
        variation: 'inverted'
      $elt


## Public API

    golem.common.widgets = widgets
