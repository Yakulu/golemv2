(function () {
  golem.home = {
    main: {
      controller: function () {
        document.title =  golem.model.title(golem.utils.locale('MENU_HOME'));
      },
      view: function (ctrl) {
        return [
          m('section', { class: 'twelve wide column' }, [
            m('p', 'Page d\'accueil')
          ]),
          m('section', { class: 'four wide column' }, [
            m('p', 'Menu contextuel')
          ])
        ];
      }
    },
  };
}).call(this);
