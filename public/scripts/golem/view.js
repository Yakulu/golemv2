(function () {
  golem.view = function (ctrl) {
    var l = golem.utils.locale;
    var dom = {
      header: m('header', [
        m('h1', { class: 'ui inverted black block small header center aligned' }, l('TITLE') + ' : ' + l('HEADER'))
      ]),
      bottomDivider: m('div', { class: 'ui horizontal icon divider' }, [ m('i', { class: 'icon html5' })]),
      footer: m('footer', [
        m('p', { class: 'ui horizontal segment center aligned' }, [
          m('span', l('FOOTER') + '('),
          m('a', { href: l('SOURCE_CODE_URL') }, l('SOURCE_CODE')),
          m('span', ')')
        ])
      ])
    };

    if (!this.mainContent) {
      this.mainContent = m('article', 'Page d\'accueil');
    }
    if (!this.contextMenuContent) {
      this.contextMenuContent = m('p', 'Zone contextuelle par défaut');
    }

    dom.main = m('main', { class: 'ui grid' }, [
      m('section', { class: 'two wide column' }, [ new golem.menus.main.view(ctrl.mainMenu) ]),
      m('section', { class: 'eleven wide column' }, [
        new golem.menus.secondary.view(ctrl.secondaryMenu), this.mainContent
      ]),
      m('section', { class: 'three wide column' }, [ this.contextMenuContent ])
    ]);

    return [
      dom.header, dom.main, dom.bottomDivider, dom.footer
    ];
  };
}).call(this);
