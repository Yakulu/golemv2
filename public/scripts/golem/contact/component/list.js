(function () {
  var contact = golem.module.contact;
  contact.component.list = {
    controller: function () {
      var l = golem.utils.locale;
      var cmi = contact.data.menuItems;
      golem.menus.secondary.items = [cmi.list, cmi.add, cmi.tags];
      document.title = golem.model.title(l('CONTACTS_LIST'));
      this.search = (function (e) {
        var val = e.target.value;
        if (val === '') {
          this.filteredItems = false;
        }
        if (val.length > 3) {
          this.filteredItems = this.items.filter(function (item) {
            var json = JSON.stringify(item).toLowerCase();
            return (json.indexOf(val.toLowerCase()) !== -1);
          });
        }
      }).bind(this);
      this.itemsPerPage = 4;
      // Cast to Integer or 1
      this.currentPage = m.prop(m.route.param('page') | 0 || 1);
      this.skipItems = (function () {
        return (this.currentPage() - 1) * this.itemsPerPage;
      }).bind(this);
      this.tagFilter = m.route.param('tag');
      var _getContacts;
      if (!this.tagFilter) {
        _getContacts = (function (cb) {
          golem.model.db.query(
            'all/bySchema', {
              startKey: ['contact'],
              endKey: ['contact', {}],
              limit: this.itemsPerPage,
              skip: this.skipItems(),
              include_docs: true 
            }, cb
          );
        }).bind(this);
      } else {
        _getContacts = (function (cb) {
          golem.model.db.query(
            'tags/count',
            {
              reduce: false,
              key: ['contact', this.tagFilter],
              include_docs: true
            },
            cb
          );
        }).bind(this);
      }
      var getContacts = (function () {
        _getContacts((function (err, results) {
          this.totalRows = results.total_rows;
          this.numberOfPages = Math.ceil(this.totalRows / this.itemsPerPage);
          this.items = results.rows;
          m.endComputation();
          }).bind(this));
      }).bind(this);
      // Init
      m.startComputation();
      contact.data.getTags(getContacts);
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
            m('div', { class: 'name' }, contact.model.fullname(c)),
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
        var searchBox = {
          head: m('div', { class: 'header item' }, l('GLOBAL_SEARCH')),
          content: m('div', { class: 'item' }, [
            m('div', { class: 'ui small icon input' }, [
              m('input', {
                type: 'search',
                placeholder: l('TYPE_HERE'),
                title: l('SEARCH_ERROR_TOO_SHORT'),
                oninput: ctrl.search
              }),
              m('i', { class: 'unhide icon' })
            ])
          ])
        };

        var activeFilter = (window.location.hash.indexOf('filter') !== -1);
        var tagsIconAttrs = { class: 'tags icon' };
        var tagsClass = '';
        if (activeFilter) {
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
              href: '#/contact/list',
              //config: m.route
            }, [
              m('i', tagsIconAttrs),
              l('BY_TAGS')
            ]),
            m('a', contact.data.tags.map(function (tag) {
              var items = [
                tag.key[1],
                m('div', { class: 'ui small teal label' }, tag.value)
              ];
              var classTag = '';
              var searchURI = decodeURI(window.location.hash);
              if (searchURI.indexOf(tag.key[1]) !== -1) {
                classTag = ' active';
                //items.push(m('i', { class: 'edit icon' }));
              }
              return m('a', {
                  class: 'item' + classTag,
                  href: '#/contact/list/filter/tag/' + tag.key[1],
                  //config: m.route
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
