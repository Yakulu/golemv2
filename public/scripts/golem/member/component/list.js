(function () {
  var module = golem.module.member;
  module.component.list = {
    controller: function () {
      var l = golem.utils.locale;
      var mi = module.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add, mi.tags, mi.skills ];
      document.title = golem.model.title(l('MEMBERS_LIST'));
      this.search = (function (e) {
        this.filteredItems = golem.component.list.search(e, this.items);
      }).bind(this);
			
      var callback = (function (err, results) {
        this.items = results.rows;
        m.endComputation();
      }).bind(this);
      this.tagFilter = this.tagFilter || false;
      this.setTagFilter = (function (tag) {
        this.tagFilter = tag;
        m.startComputation();
        golem.model.db.query(
          'tags/count',
          {
            reduce: false,
            key: ['member', this.tagFilter],
            include_docs: true
          }, callback
        );
      }).bind(this);
      this.unsetTagFilter = (function () {
        this.tagFilter = false;
        getMembers();
      }).bind(this);
			
      // Init
      this.items = [];
      var getMembers = (function () {
        m.startComputation();
        golem.model.db.query(
          'all/bySchema',
          {
            startkey: ['member'],
            endkey: ['member', {}],
            include_docs: true,
          }, callback
				);
			}).bind(this)
      module.data.getTags(getMembers);
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var itemDom = function (f) {
        f = f.doc;
        return m('tr', [
          m('td', module.model.fullname(f)),
          //m('td', f.family),
          m('td', module.model.fulladdress(f)),
          m('td', f.tels.map(function (tel) {
            if (tel.default) {
              return tel.value.match(/\d{2}/g).join('.');
            }
          })),
          m('td', f.mails.map(function (mail) {
            if (mail.default) {
              return m('a', { href: 'mailto:' + mail.value }, mail.value);
            }
          })),
          m('td', { class: 'actions' }, [
            m('a', { href: '#/member/show/' + f._id, title: l('VIEW') }, [
              m('i', { class: 'unhide icon' })
            ]),
            m('a', { href: '#/member/edit/' + f._id, title: l('EDIT') }, [
              m('i', { class: 'edit icon' })
            ]),
            m('a', { href: '#/member/remove/' + f._id, title: l('DELETE') }, [
              m('i', { class: 'remove icon' })
            ])
          ])
        ]);
      };
      var itemsDom = ctrl.filteredItems ? ctrl.filteredItems.map(itemDom) : ctrl.items.map(itemDom);
      var mainContent = m('section', { class: 'twelve wide column' }, [
        m('table', { class: 'ui basic table' }, [
          m('thead', [
            m('tr', [
              m('th', l('LASTNAME')),
              //m('th', l('FAMILY')),
              m('th', l('CITY')),
              m('th', [
                l('TEL'),
                m('i', { class: 'icon info', title: l('DEFAULT_ONLY') })
              ]),
              m('th', [
                l('MAIL'),
                m('i', { class: 'icon info', title: l('DEFAULT_ONLY') })
              ]),
              m('th', { width: '10%' }, l('ACTIONS'))
            ])
          ]),
          m('tbody', itemsDom)
        ])
      ]);
      var searchBox = golem.component.list.searchBox(ctrl.search);
			var tagsBox = golem.component.list.tagsBox(module.data.tags, ctrl);
      var contextMenuContent = m('section', { class: 'four wide column' }, 
        m('nav', [
          m('menu', { class: 'ui small vertical menu' }, [
            searchBox.head, searchBox.content,
						tagsBox.head, tagsBox.tags
          ])
        ])
      );
      return [
        m('section', { class: 'twelve wide column' }, [
          new golem.menus.secondary.view(), mainContent
        ]),
        m('section', { class: 'four wide column' }, contextMenuContent)
      ];
    }
  };
}).call(this);
