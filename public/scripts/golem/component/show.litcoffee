# Show component

This module gathers common functions for show components.

    show =

## Formats Helpers

Here are view helpers for formatting pieces of objects :

- `default` : add a little checked icon when the corresponding field is true
- `tels`: formats the phone numbers for better readability and push the
  `default` format if needed
- `mails`: formats the mail addresses for using on mail apps and push the
  `default` format if needed
- `www`: returns a Web link with its value

      format:
        default: (def) ->
          if def
            span [
              i
                class: 'checkmark icon green'
                title: L 'DEFAULT'
            ]

        tels: (item) ->
          li [
            "#{item.label} : "
            a
              href: "tel:#{item.value}",
              item.value.match(/\d{2}/g).join '.'
            show.format.default item.default
          ]

        mails: (item) ->
          li [
            "#{item.label} : "
            a
              href: "mailto:#{item.value}"
              item.value
            show.format.default item.default
          ]

        www: (item) ->
          li [
            a { href: item }, item
          ]

## Multi container

`multi` is a simple container around different `items`, formatted with a
`formatFn` function and with the specicied `header`.

      multi: (header, items, formatFn) ->
        if items.length > 0
          div [
            div { class: 'ui black label' }, header
            ul items.map formatFn
          ]

## Public API

    golem.component.show = show
