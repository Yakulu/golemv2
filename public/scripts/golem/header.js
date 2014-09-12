(function () {
  var l = golem.config.locale;
  golem.header = {
    controller: function () {},
    view: function () {
      return m('h1',
        { class: 'ui inverted black block small header center aligned' },
        l.TITLE + ' : ' + l.HEADER);
    }
  };
}).call(this);
