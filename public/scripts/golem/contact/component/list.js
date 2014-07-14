(function () {
  var module = golem.module.contact;
  module.component.list = {
    controller: function () {
      var l = golem.utils.locale;
      var cmi = module.data.menuItems;
      golem.menus.secondary.items = [cmi.list, cmi.add, cmi.tags];
      document.title = golem.model.title(l('CONTACTS_LIST'));
      this.search = (function (e) {
        this.filteredItems = golem.component.list.search(e, this.items);
      }).bind(this);
      this.items = [];
      this.itemsPerPage = 4;
      // Cast to Integer or 1
      this.currentPage = m.prop(m.route.param('page') | 0 || 1);
      this.skipItems = (function () {
        return (this.currentPage() - 1) * this.itemsPerPage;
      }).bind(this);
      var callback = (function (err, results) {
        this.totalRows = results.rows.length;
        this.numberOfPages = Math.ceil(this.totalRows / this.itemsPerPage);
        this.items = results.rows;
        m.endComputation();
      }).bind(this);
      //this.tagFilter = m.route.param('tag');
      this.tagFilter = this.tagFilter || false;
      this.setTagFilter = (function (tag) {
        this.tagFilter = tag;
        m.startComputation();
        golem.model.db.query(
          'tags/count',
          {
            reduce: false,
            key: ['contact', this.tagFilter],
            include_docs: true
          }, callback
        );
      }).bind(this);
      this.unsetTagFilter = (function () {
        this.tagFilter = false;
        getContacts();
      }).bind(this);

      // Init
      var getContacts = (function() {
        m.startComputation();
        golem.model.db.query(
          'all/bySchema', {
            startkey: ['contact'],
            endkey: ['contact', {}],
            limit: this.itemsPerPage,
            skip: this.skipItems(),
            include_docs: true 
          }, callback
        );
      }).bind(this);
      var md = module.data;
      md.getTags(getContacts);
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var contactItemDom = function (c) {
        c = c.doc;
        var showURL = '#/contact/show/' + c._id;
        var editURL = '#/contact/edit/' + c._id;
        var removeURL = '#/contact/remove/' + c._id;

        return m('li', { class: 'contact item' }, [
          m('div', { class: 'content' }, [
            m('div', { class: 'meta' }, [
              m('a', { href: showURL, /*config: m.route*/ }, [
                m('i', { class: 'unhide icon' })
              ]),
              m('a', { href: editURL, /*config: m.route*/ }, [
                m('i', { class: 'edit icon' })
              ]),
              m('a', { href: removeURL, /*config: m.route*/ }, [
                m('i', { class: 'remove icon' })
              ])
            ]),
            m('div', { class: 'name' }, module.model.fullname(c)),
            m('p', { class: 'description' }, [
              m('p', c.postalCode + ' ' + c.city),
              m('p', [
                m('div', c.tels.map(function(tel) {
                  if (tel.default) {
                    return tel.value.match(/\d{2}/g).join('.');
                  }
                })),
                m('div', c.mails.map(function (mail) {
                  if (mail.default) {
                    return m('a', { href: 'mailto:' + mail.value }, mail.value);
                  }
                }))
              ])
            ])
          ])
        ]);
      };
      var mainContent = (function () {
        var itemsDom;
        if (ctrl.filteredItems) {
          itemsDom = ctrl.filteredItems.map(contactItemDom);
        } else {
          itemsDom = ctrl.items.map(contactItemDom);
        }
        var pagesDom = [];
        if (!ctrl.filteredItems && !ctrl.tagFilter) {
          var aProps = function (cond, page) {
            if (cond) {
              return { class: 'disabled item' };
            } else {
              return {
                class: 'icon item',
                href: '#/contact/list/page/' + page
              };
            }
          };
          var aPrevProps = aProps(ctrl.currentPage() <= 1, ctrl.currentPage() - 1);
          pagesDom.push(
            m('a', aPrevProps, [
              m('i', { class: 'left arrow icon' })
            ])
          );
          for (var pi = 1; pi <= ctrl.numberOfPages; pi++) {
            if (pi === ctrl.currentPage()) {
              pagesDom.push(m('div', { class: 'disabled item' }, pi));
            } else {
              pagesDom.push(m('a.item', {
                href: '#/contact/list/page/' + pi
              }, pi));
            }
          }
          var aNextProps = aProps(ctrl.currentPage() === ctrl.numberOfPages, ctrl.currentPage() + 1);
          pagesDom.push(m('a', aNextProps, [
            m('i', { class: 'right arrow icon' })
          ]));
        }
        return m('p', [
          m('ul', {
            id: 'contacts',
            class: 'ui one items'
            }, itemsDom),
          m('div', { class: 'ui pagination menu' }, pagesDom)
        ]);
      }).call(this);

      var contextMenuContent = (function () {
        var searchBox = golem.component.list.searchBox(ctrl.search);
        var tagsIconAttrs = { class: 'tags icon' };
        var tagsClass = '';
        if (ctrl.tagFilter) {
          tagsIconAttrs = { class: 'eraser icon', title: l('FILTERS_REMOVE') };
          tagsClass = ' active';
        }
        var filtersBox = {
          head: m('div', { class: 'header item' }, l('FILTERS')),
          groups: m('a', { class: 'item' }, [
            m('i', { class: 'users icon' }),
            l('BY_GROUPS')
          ]),
          tags: m('div', [
            m('a', {
              class: 'item' + tagsClass,
              onclick: ctrl.unsetTagFilter
              //config: m.route
            }, [
              m('i', tagsIconAttrs),
              l('BY_TAGS')
            ]),
            m('a', module.data.tags.map(function (tag) {
              var items = [
                tag.key[1],
                m('div', { class: 'ui small teal label' }, tag.value)
              ];
              var classTag = 'item';
              if (ctrl.tagFilter === tag.key[1]) { classTag += ' active'; }
              return m('a', {
                  class: classTag,
                  onclick: ctrl.setTagFilter.bind(ctrl, tag.key[1])
                }, items);
            })
            )
          ])
        };
        return m('nav', [
          m('menu', { class: 'ui small vertical menu' }, [
            searchBox.head,
            searchBox.content,
            filtersBox.head,
            filtersBox.tags
          ])
        ]);
      }).call(this);
      return [
        m('section', { class: 'twelve wide column' }, [
          new golem.menus.secondary.view(), mainContent
        ]),
        m('section', { class: 'four wide column' }, contextMenuContent)
      ];
    }
  };
}).call(this);
