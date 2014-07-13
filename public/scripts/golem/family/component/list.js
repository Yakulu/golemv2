(function () {
  var module = golem.module.family;
  module.component.list = {
    controller: function () {},
    view: function (ctrl) {
      return [
        m('section', { class: 'twelve wide column' }, [
          m('p', 'Families!!')
        ]),
        m('section', { class: 'four wide column' }, 'context')
      ];
    }
  };
}).call(this);
