(function () {
  var l = golem.config.locale;
  golem.component.show = {
    format: {
      default: function (def) {
        if (def) {
          return m('span', [
            m('i', {
              class: 'checkmark icon green',
              title: l.DEFAULT
              }
            )
          ]);
        }
      },
      tels: function (item) {
        return m('li', [
          item.label + ' : ',
          m('a', { href: 'tel:' + item.value },
            item.value.match(/\d{2}/g).join('.')),
          golem.component.show.format.default(item.default)
        ]);
      },
      mails: function (item) {
        return m('li', [
          item.label + ' : ',
          m('a', { href: 'mailto:' + item.value }, item.value),
          golem.component.show.format.default(item.default)
        ]);
      },
      www: function (item) {
        return m('li', [ m('a', { href: item }, item) ]);
      }
    },
    multiBox: function (items, header, formatFn) {
      if (items.length > 0) {
        return m('div', [
          m('div', { class: 'ui black label' }, header),
          m('ul', items.map(formatFn))
        ]);
      }
    }
  }
}).call(this);
