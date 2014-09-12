(function () {
  golem.widgets.common = {
    modal: {
      controller: function (config) {
        var me = this;
        // Defaults
        me.active = config.active || false;
        me.toggle = function () {
          me.active = !me.active;
        };
        // Init
        me.title = config.title;
        me.content = config.content;
        me.cancelFn = config.cancelFn || me.toggle;
        me.acceptFn = config.acceptFn;
      },
      view: function (ctrl) {
        var l = golem.utils.locale;
        var cls = '';
        if (ctrl.active) { cls += ' active visible'; }
        return m('div', { class: 'ui dimmer page' + cls }, [
          m('div', { class: 'ui basic modal' + cls }, [
            m('i', { class: 'close icon', onclick: ctrl.cancelFn }),
            m('div', { class: 'header' }, ctrl.title),
            m('div', { class: 'content' }, ctrl.content),
            m('div', { class: 'actions' }, [
              m('button',
                {
                  class: 'ui negative button',
                  type: 'button',
                  onclick: ctrl.cancelFn
                } , l('CANCEL')),
                m('button',
                  {
                    class: 'ui positive button',
                    type: 'button',
                    onclick: ctrl.acceptFn
                  }, l('OK'))
            ])
          ])
        ]);
      }
    },
    notification: {
      controller: function (config) {
        // Defaults
        config.timeout = timeout || 5;
        // Init
        me.title = config.title;
        me.body = config.body;
        me.displayed = true;
        // Methods
        me.toggle = function () {
          me.displayed = !me.displayed;
        };
        me.click = function () { console.log('click'); };
      },
      view: function (ctrl) {
        return m('div',
          { class: 'ui message notification',
            style: { display: ctrl.displayed ? 'block' : 'none' },
            onclick: ctrl.click
          },
          [
            m('i', { class: 'close icon', onclick: ctrl.toggle }),
            m('div', { class: 'header' }, ctrl.title),
            m('p', ctrl.body)
          ]
        );
      }
    }
  };
}).call(this);
