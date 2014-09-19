# Widgets - common


These widgets can be used everywhere in the GOLEM application.

## Header expandable

The `$headerExpandable` is a widget that is intended to show a header that can
be opened and closed with an icon. It just toggles a boolean, wich will be used
to toggle the whole content. `$headerExpandable` take a `config` object as
argument with a `title`, a `class` and the boolean `active`. All are required.

    $headerExpandable = (c) ->
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

## Public API

    golem.widgets.common =
      headerExpandable: $headerExpandable
      modal: modal
