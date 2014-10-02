l = golem.config.locale
golem.component.show =
  format:
    default: (def) ->
      if def
        m 'span', [
          m 'i',
            class: 'checkmark icon green'
            title: l.DEFAULT
        ]

    tels: (item) ->
      m 'li', [
        "#{item.label} : "
        m 'a',
          href: "tel:#{item.value}",
          item.value.match(/\d{2}/g).join('.')
        golem.component.show.format.default item.default
      ]

    mails: (item) ->
      m 'li', [
        "#{item.label} : "
        m 'a',
          href: "mailto:#{item.value}"
          item.value
        golem.component.show.format.default item.default
      ]

    www: (item) ->
      m 'li', [
        m 'a', { href: item }, item
      ]

  multiBox: (items, header, formatFn) ->
    if items.length > 0
      m 'div', [
        m 'div', { class: 'ui black label' }, header
        m 'ul', items.map formatFn
      ]
