(function () {
  golem.notifications = {
    model: {
      items: {}, // list of items by id -> item
      counter: 0 // id autoincrement
    },
    controller: function () {
      // Only 1 controller base on the model
      // View with loop on items...
      var gnm = golem.notifications.model;
      this.toClose = {};
      this.close = (function (id, from) {
        if (from && from !== 'timeout') { // with from false, no clear because notimeout
          window.clearTimeout(this.toClose[id]);
        }
        delete this.toClose[id];
        delete gnm.items[id];
      }).bind(this);
      this.delayClose = (function (id, timeout) {
        if (timeout && !this.toClose[id]) {
          this.toClose[id] = window.setTimeout((function () {
            this.close(id, 'timeout');
            m.redraw();
          }).bind(this), timeout * 1000);
        }
      });
    },
    view: function (ctrl) {
      var gnm = golem.notifications.model;
      var keys = Object.keys(gnm.items).sort().reverse();
      return m('div', keys.map(function (id) {
        var n = gnm.items[id];
        ctrl.delayClose(id, n.timeout);
        var closeFn = ctrl.close.bind(ctrl, id, n.timeout)
        var notifClass = ['ui', 'floating', 'message', 'notification'];
        if (n.cls) { notifClass.push(n.cls); };
        if (n.icon) { notifClass.push('icon'); }
        return m('div',
          {
            class: notifClass.join(' '),
            onclick: n.click ? n.click : closeFn
          },
          [
            n.icon ? m('i', { class: 'inbox icon' }): '',
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
