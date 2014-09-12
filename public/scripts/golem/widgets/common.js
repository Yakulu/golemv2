(function () {
  golem.widgets.common = {
    modal: {
      controller: function (config) {
        // Defaults
        this.active = config.active || false;
        this.toggle = (function () {
          this.active = !this.active;
        }).bind(this);
        // Init
        this.title = config.title;
        this.content = config.content;
        this.cancelFn = config.cancelFn || this.toggle;
        this.acceptFn = config.acceptFn;
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
        this.title = config.title;
        this.body = config.body;
        this.displayed = true;
        // Methods
        this.toggle = (function () {
          this.displayed = !this.displayed;
        }).bind(this);
        this.click = function () { console.log('click'); };
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
