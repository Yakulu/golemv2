(function () {
  golem.notifications = {
    model: {
      items: []
    },
    controller: function () {
      // Only 1 controller base on the model
      // View with loop on items...
      var items = golem.notifications.model.items;
      var timeouts = {};
      window.timeouts = timeouts;
      this.close = function (idx) {
        //window.clearTimeout(this.timeouts[idx]);
        //delete timeouts[idx];
        items.splice(idx, 1); 
      };
      this.nDelayClose = function (idx, timeout, closeFn, element, isInitialized) {
        if (!isInitialized) {
          if (timeout) {
            timeouts[idx] = window.setTimeout(function () {
              var parent = element.parentNode;
              //parent.removeChild(element);
              //items.pop(); // FIXME: can be a problem with closes and different timeouts
              closeFn(idx); // FIXME: can be a problem with closes and different timeouts
              //m.redraw();
            }, timeout * 1000); 
          }
        }
      };
    },
    view: function (ctrl) {
      return m('div', golem.notifications.model.items.map(function (n, idx) {
        var notifClass = ['ui', 'floating', 'message', 'notification'];
        if (n.cls) { notifClass.push(n.cls); };
        if (n.icon) { notifClass.push('icon'); }
        return m('div',
          {
            id: idx,
            config: ctrl.nDelayClose.bind(ctrl, idx, n.timeout, ctrl.close),
            class: notifClass.join(' '),
            onclick: n.click ? n.click : ctrl.close.bind(ctrl, idx)
          },
          [
            n.icon ? m('i', { class: 'inbox icon' }): '',
            m('i', { class: 'close icon', onclick: ctrl.close.bind(ctrl, idx) }),
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
