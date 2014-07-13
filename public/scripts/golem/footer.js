(function () {
  var l = golem.utils.locale;
  golem.footer = {
    controller: function () {},
    view: function () {
      return [
        m('div', { class: 'ui horizontal icon divider' }, [ m('i', { class: 'icon html5' })]),
        m('p', { class: 'ui horizontal segment center aligned' }, [
          m('span', l('FOOTER') + '('),
          m('a', { href: l('SOURCE_CODE_URL') }, l('SOURCE_CODE')),
          m('span', ')')
        ])
      ]
    }
  };
}).call(this);
