(function () {
  golem.notifications = {
    model: {
      items: {}, // list of items by id -> item
      counter: 0 // id autoincrement
    },
    controller: function () {
      var me = this;
      var gnm = golem.notifications.model;
      me.toClose = {};
      me.close = function (id, from) {
        if (from && from !== 'timeout') { // with from false, no clear because notimeout
          window.clearTimeout(me.toClose[id]);
        }
        delete me.toClose[id];
        delete gnm.items[id];
      };
      me.delayClose = function (id, timeout) {
        if (timeout && !me.toClose[id]) {
          me.toClose[id] = window.setTimeout(function () {
            me.close(id, 'timeout');
            m.redraw();
          }, timeout * 1000);
        }
      };
    },
    view: function (ctrl) {
      var gnm = golem.notifications.model;
      var keys = Object.keys(gnm.items).sort();
      return m('div', keys.map(function (id) {
        var n = gnm.items[id];
        ctrl.delayClose(id, n.timeout);
        var closeFn = ctrl.close.bind(ctrl, id, n.timeout)
        var notifClass = ['ui', 'floating', 'message', 'notification'];
        if (n.cls) { notifClass.push(n.cls); };
        if (n.icon) { notifClass.push('icon'); };
        return m('div',
          {
            class: notifClass.join(' '),
            onclick: n.click ? n.click : closeFn
          },
          [
            n.icon ? m('i', { class: n.icon + ' icon' }): '',
            m('i', { class: 'close icon', onclick: closeFn }),
            m('div.content', [
              m('div.header', n.title),
              m('p', n.body)
            ])
          ]
        );
      }));
    }
  };
}).call(this);
