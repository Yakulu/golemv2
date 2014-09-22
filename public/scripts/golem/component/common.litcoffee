# Widgets - common


These components can be used everywhere in the GOLEM application.

## Header expandable

The `$headerExpandable` is a component that is intended to show a header that
can be opened and closed with an icon. It just toggles a boolean, wich will be
used to toggle the whole content. `$headerExpandable` take a `config` object as
argument with a `title`, a `class` and the boolean `active`. All are required.

    $headerExpandable = (c) ->
      toggleActive = -> c.active.set(not c.active.get())
      h3 { class: "ui header #{c.class}" }, [
        span [
          c.title + ' '
          i
            class: bind -> if c.active.get() then 'icon collapse' else 'icon expand'
            style: { cursor: 'pointer' }
            click: toggleActive
        ]
      ]

## Modal

    modal = ->

## Public API

    golem.component.common =
      $headerExpandable: $headerExpandable
      modal: modal
