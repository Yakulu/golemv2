(function () {
  'use strict';

  // GOLEM
  golem.utils = {
    locale: function (str) { return golem.config.locale[str]; },
    sendNotification: function (title, options, callback) {
      var _send = function () {
        var notif = new Notify(title, options);
        notif.show();
        callback();
      };
      var _alert = function () {
        alert(title + ' : ' + options.body); 
        callback();
      };
      if (!Notify.isSupported()) {
        _alert();
      } else {
        if (Notify.needsPermission()) {
          Notify.requestPermission(_send, _alert);
        } else {
          _send();
        }
      }
    }
  };

  golem.model = {
    db: new PouchDB('golem'),
    queries: {
      all: {
        _id: '_design/all',
        views: {
          bySchema: {
            map: function (doc) {
              if (doc.schema) {
                emit([doc.schema, doc.creationDate], null);
              }
            }.toString()
          }
        }
      },
      tags: {
        _id: '_design/tags',
        views: {
          count: {
            map: function (doc) {
              var emitProp = function (schema, prop) {
                schema = schema || doc.schema;
                prop = prop || 'tags';
                for (var i = 0, l = doc[prop].length; i < l; i++) {
                  emit([schema, doc[prop][i]]);
                }
              };
              if (doc.tags) {
                emitProp();
              }
              if ((doc.schema === 'member') && doc.skills) {
                emitProp('memberskills', 'skills');
              }
            }.toString(), reduce: '_count'
          }
        }
      }
    }
  };

  golem.controller = function () {
    this.docTitle = golem.utils.locale('TITLE') + ' - ';
    document.title =  this.docTitle + golem.utils.locale('MENU_HOME');

    this.mainMenu = new menus.main.controller();
    this.secondaryMenu = new menus.secondary.controller();
  };
  golem.view = function (ctrl) {
    var l = golem.utils.locale;
    var dom = {
      header: m('header', [
        m('h1', { class: 'ui inverted black block small header center aligned' }, l('TITLE') + ' : ' + l('HEADER'))
      ]),
      bottomDivider: m('div', { class: 'ui horizontal icon divider' }, [ m('i', { class: 'icon html5' })]),
      footer: m('footer', [
        m('p', { class: 'ui horizontal segment center aligned' }, [
          m('span', l('FOOTER') + '('),
          m('a', { href: l('SOURCE_CODE_URL') }, l('SOURCE_CODE')),
          m('span', ')')
        ])
      ])
    };

    if (!this.mainContent) {
      this.mainContent = m('article', 'Page d\'accueil');
    }
    if (!this.contextMenuContent) {
      this.contextMenuContent = m('p', 'Zone contextuelle par défaut');
    }

    dom.main = m('main', { class: 'ui grid' }, [
      m('section', { class: 'two wide column' }, [ new menus.main.view(ctrl.mainMenu) ]),
      m('section', { class: 'eleven wide column' }, [
        new menus.secondary.view(ctrl.secondaryMenu), this.mainContent
      ]),
      m('section', { class: 'three wide column' }, [ this.contextMenuContent ])
    ]);

    return [
      dom.header, dom.main, dom.bottomDivider, dom.footer
    ];
  };

  // Model Validations
  // TODO, and types like url, email and co
  var validations = {
    required: function (val) {
      return (val && val.length !== 0);
    },
    min: function (val, rule) {
      return parseInt(val) >= rule;
    },
    max: function (val, rule) {
      return parseInt(val) <= rule;
    },
    minlength: function (val, rule) {
      return val.length >= rule;
    },
    maxlength: function (val, rule) {
      return val.length <= rule;
    },
    pattern: function (val) {
      return new Regexp(pattern).test(val);
    },
    contact: {
      rules : {
        firstname: {}
        // ...
      },
      messages: {
        firstname: {}
        // ...
      }
    }
  };

  // Menus
  var menus = {
    Item: function (title, baseUrl, icon, cls) {
      this.title = title;
      this.baseUrl = baseUrl;
      this.icon = icon;
      this.cls = cls || 'item';
      this.url = this.baseUrl;
    },
    itemDom: function (item) {
      var cls = item.cls;
      if (window.location.hash.indexOf(item.url) !== -1) {
        cls += ' active';
      }
      return m('a',
        {
          class: cls,
          href: '#' + item.url,
          // Temp fix for laggy rendering
          //config: m.route
        },
        [
          m('i', { class: item.icon + ' icon' }),
          item.title
        ]
      );
    },
    main: {
      controller: function () {
        var l = golem.utils.locale;
        this.items = [
          new menus.Item(l('MENU_HOME'), '/home', 'home'),
          new menus.Item(l('MENU_CONTACTS'), '/contact', 'book'),
          new menus.Item(l('MENU_MEMBERS'), '/member', 'user'),
          new menus.Item(l('MENU_MESSAGES'), '/mail', 'mail', 'item disabled'),
          new menus.Item(l('MENU_ACTIVITIES'), '/activity', 'globe'),
          new menus.Item(l('MENU_STATISTICS'), '/stats', 'pie chart basic', 'item disabled')
          ];

          this.addItem = function (title, baseUrl, icon, cls) {
            this.items.push(new menus.Item(title, baseUrl, icon, cls));
          };
      },
      view: function (ctrl) {
        return m('nav', [
          m('menu', {
              id: 'main-menu',
              class: 'ui vertical labeled icon menu'
            },
            ctrl.items.map(menus.itemDom)
          )
        ]);
      }
    },
    secondary: {
      controller: function () {
        this.items = [];

        this.replace = function (items) {
          this.items = items;
        };
      },
      view: function (ctrl) {
        return m('nav', [
          m('menu', {
              class: 'ui small secondary pointing menu'
            },
            ctrl.items.map(menus.itemDom)
          )
        ]);
      }
    }
  };

  // Global Widgets
  var widgets = {
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
    }
  };
  // Form commons
  var form = {
    addButton: function (clickAction, text) {
     return m('button', {
       class: 'ui right attached tiny button',
       type: 'button',
       onclick: clickAction,
       }, [ m('i', { class: 'add sign icon' }), text ]
     );
    },
    helpButton: {
      controller: function (title, content, extra) {
        this.title = title;
        this.content = content;
        this.extra = extra;
        this.isPopupVisible = false;
        this.togglePopup = (function () {
          this.isPopupVisible = !this.isPopupVisible;
        }).bind(this);
      },
      view: function (ctrl) {
        var l = golem.utils.locale;
        var box = [];
        var cls = 'ui tiny button';
        if (ctrl.extra) {
          cls += ' left attached';
          box.push(ctrl.extra);
        }
        box.unshift(
          m('button',
            {
              class: ctrl.isPopupVisible ? cls + ' black' : cls,
              type: 'button',
              'data-title': ctrl.title,
              'data-content': ctrl.content,
              onclick: ctrl.togglePopup
            },
            [ m('i', { class: 'help icon' }), l('HELP') ]
          )
        );
        var popup = m('div', {
            class: 'ui visible center right inverted popup helper'
          }, [
            m('div', { class: 'header' }, [
              m('i',
                {
                  role: 'button',
                  class: 'close icon',
                  onclick: ctrl.togglePopup
                }
              ),
              ctrl.title
            ]),
            m('p', { class: 'content' }, m.trust(ctrl.content))
          ]
        );
        if (ctrl.isPopupVisible) { box.unshift(popup); }
        return m('div', box);
      }
    },
    inputHelper: function (config) {
      // Defaults
      var placeholder = config.placeholder || config.label;
      var type = config.type || 'text';
      var name = config.name + (config.suffix || '');
      // Attributes
      var inputAttr = {
        id: name,
        name: name,
        type: type,
        placeholder: placeholder,
        value: config.value
      };
      if (config.maxlength) { inputAttr.maxlength = config.maxlength; }
      if (config.minlength) { inputAttr.minlength = config.minlength; }
      if (config.size) { inputAttr.size = config.size; }
      if (config.required) { inputAttr.required = 'required'; }
      if (config.onchange) { inputAttr.onchange = config.onchange; }
      // Element
      return m('input', inputAttr);
    },
    textHelper: function (config) {
      var labelText;
      if (config.required) {
        labelText = '* ' + config.label;
      } else {
        labelText = config.label;
      }
      var label = m('label', { for: config.name }, labelText);
      return m('div', { class: 'field small input' }, [
        label,
        form.inputHelper(config)
      ]);
    },
    multiFieldWidget: {
      // TODO : non trivial, make fidel representation of fields in reactive elements for m.withAttr...
      controller: function (config) {
        var l = golem.utils.locale;
        // Internal state
        this.type = config.type;
        this.label = config.label;
        this.name = config.name;
        this.size = config.size;
        this.maxlength = config.maxlength;
        this.minlength = config.minlength;
        this.content = config.content;
        // Defaults
        this.required = config.required || 'required';
        this.placeholder = config.placeholder || '';
        this.radioField = config.radioField || false;
        this.labelField = config.labelField || false;
        this.removeNum = m.prop();
        this.suffix = m.prop();
        this.value = '';
        // Reactive element
        this.current = config.current;
        // Methods
        this.setSuffix = (function (num) {
          this.suffix = '-' + num;
        }).bind(this);
        this.setValue = (function (obj) {
          if (obj.value !== undefined) {
            this.value = obj.value;
          } else {
            this.value = obj;
          }
        }).bind(this);
        this.addField = (function () {
          var field;
          if (!this.labelField) {
            field = '';
          } else {
            field = { label: '', value: '' };
            if (this.radioField) { field.default = false; }
          }
          this.current.push(field);
        }).bind(this);
        this.change = function (num, field, e) {
          switch (field) {
            case 'default':
              for (var i = 0, l = this.current.length; i < l; i++) {
                this.current[i].default = (i === num);
              }
              break;
            case 'www':
              this.current[num] = e.target.value;
              break;
            default: // Label and classic value
              this.current[num][field] = e.target.value;
          }
        };
        // Children Modules
        this.helpButton = new form.helpButton.controller(
          this.label,
          this.content,
          form.addButton(this.addField, l('MENU_NEW'))
        );
        // Remove Modal
        var removeField = (function () {
          this.current.splice(this.removeNum(), 1);
          this.removeModalCtrl.toggle();
        }).bind(this);
        this.removeModalCtrl = new widgets.modal.controller({
          title: l('SURE'),
          content: l('REMOVE_FIELD_CONFIRM_MSG'),
          acceptFn: removeField
        });
      },
      view: function (ctrl) {
        var l = golem.utils.locale;
        // Buttons
        // Input and remove fields
        var inputRemoveFields = function (num) {
          ctrl.setSuffix(num);
          var fields = [];
          var sel = ctrl.current[num];
          // Radio field
          if (ctrl.radioField) {
            var checked;
            if (sel) {
              checked = sel.default;
            } else {
              checked = false;
            }
            var radioField = m('input',
              {
                class: 'ui radio checkbox',
                title: l('DEFAULT'),
                type: 'radio',
                name: ctrl.name + '-default',
                required: 'required',
                value: num,
                checked: checked,
                onchange: ctrl.change.bind(ctrl, num, 'default')
            });

            fields.push(m('div', { class: 'field' }, [
              radioField,
              m('label',
                { class: 'small', for: ctrl.name },
                l('DEFAULT'))
            ]));
          }

          // Label field
          if (ctrl.labelField) {
            var fieldId = ctrl.name + '-label-' + num;
            var labelField = m('div', { class: 'field' }, [
              m('input', {
                type: 'text',
                list: fieldId,
                name: fieldId,
                placeholder: l('TYPE'),
                size: 15,
                value: sel ? sel.label : '',
                onchange: ctrl.change.bind(ctrl, num, 'label')
              }),
              m('datalist', { id: fieldId },
                contact.data.labels[ctrl.name].map(function (label) {
                  return m('option', { value: label });
                })
              )
            ]);
            fields.push(labelField);
          }

          // Remove button
          var removeField = m('div', {
            role: 'button',
            class: 'ui tiny red icon button',
            title: l('DELETE'),
            onclick: function () {
              ctrl.removeNum(num);
              ctrl.removeModalCtrl.toggle();
            }
          }, [ m('i', { class: 'remove sign icon' }) ]);
          // All fields
          ctrl.setValue(sel);


          if (!ctrl.labelField) {
            ctrl.onchange = ctrl.change.bind(ctrl, num, 'www');
          } else { // Complex fields like mail and tel
            ctrl.onchange = ctrl.change.bind(ctrl, num, 'value');
          }
          fields.push(m('div', { class: 'field' }, [
              m('div', { class: 'ui action input' }, [
                form.inputHelper(ctrl),
                removeField
              ])
            ])
          );
          return m('div', { class: 'multitext fields inline' }, fields);
        };

        var fieldset = m('fieldset', { class: 'ui segment' }, [
          m('legend', ctrl.label),
          new form.helpButton.view(ctrl.helpButton),
          m('div', ctrl.current.map(function (item, i) {
            return inputRemoveFields(i);
          })),
          new widgets.modal.view(ctrl.removeModalCtrl)
        ]);

        return m('div', { class: 'field' }, [ fieldset ]);
      }
    },
    tagWidget: {
      controller: function (config) {
        // Initialization
        this.label = config.label;
        this.placeholder = config.placeholder;
        this.content = config.content;
        // Defaults
        this.size = config.size || 10;
        this.name = config.name || 'tags';
        // All tags except those already selected
        var tags = config.tags.filter(function (tag) {
          return (config.current.indexOf(tag) === -1);
        });
        // Reactive elements
        this.tags = tags;
        this.current = config.current;
        // Children modules
        this.helpButton = new form.helpButton.controller(this.label, this.content);
        // Methods
        this.add = (function (input) {
          var v = input.value;
          if (v && this.current.indexOf(v) === -1) {
            this.current.push(v);
            //config.model[this.name].push(v); 
          }
          var vIdx = this.tags.indexOf(v);
          if (vIdx !== -1) {
            this.tags.splice(vIdx, 1);
          }
          input.value = '';
        }).bind(this);
      },
      view: function (ctrl) {
        var l = golem.utils.locale;
        return m('div', { class: 'field tagfield' }, [
          m('fieldset', { class: 'ui segment' }, [
            m('legend', ctrl.label),
            new form.helpButton.view(ctrl.helpButton),
            m('div', { class: 'ui action input multitext' }, [
              m('input', {
                id: ctrl.name + '-input',
                name: ctrl.name,
                type: 'text',
                list: ctrl.name,
                placeholder: ctrl.placeholder,
                size: ctrl.size,
                onkeydown: function (e) {
                  if (e.keyCode === 13) { // Enter
                    e.preventDefault();
                    ctrl.add(e.target);
                  }
                },
                onchange: function (e) { ctrl.add(e.target); }
              }),
              m('div', {
                role: 'button',
                class: 'ui mini purple button',
                onclick: function (e) {
                  var ipt = document.getElementById(ctrl.name + '-input');
                  ctrl.add(ipt);
                }
              }, l('OK'))
            ]),
            m('datalist', { id: ctrl.name }, ctrl.tags.map(function (tag) {
              return m('option', { value: tag });
            })),
            m('p', ctrl.current.map(function (tag) {
              return m('div', { class: 'ui label purple golem-tag' }, [
                tag,
                m('i', {
                  role: 'button',
                  class: 'delete icon',
                  onclick: function (e) {
                    var value = e.target.parentElement.textContent;
                    var idx = ctrl.current.indexOf(value);
                    ctrl.current.splice(idx, 1);
                    ctrl.tags.push(value);
                    //$target.empty()
                  }
                })
              ]);
            }))
          ])
        ]);
      }
    }
  };
  // Contacts
  var contact = {
    modules: {},
    data: {}
  };
  window.contact = contact;

  contact.data.menuItems = (function () {
    var l = golem.utils.locale;
    return {
      list: new menus.Item(l('MENU_LIST'), '/contact/list', 'list'),
      add: new menus.Item(l('MENU_NEW'), '/contact/add', 'add sign'),
      //groups: new menus.Item(l('MENU_GROUPS'), '/contact/groups', 'users'),
      tags: new menus.Item(l('MENU_TAGS'), '/contact/tags', 'tags'),
      show: new menus.Item(l('VIEW'), '/contact/show', 'search'),
      edit: new menus.Item(l('EDIT'), '/contact/edit', 'edit'),
      remove: new menus.Item(l('DELETE'), '/contact/remove', 'remove')
    };
  }).call();

  contact.model = {
    create: function (props) {
      return {
        schema: 'contact',
        creationDate: Date.now(),
        firstname: props.firstname || '',
        lastname: props.lastname || '',
        address: props.address || '',
        postalCode: props.postalCode || '',
        city: props.city || '',
        note: props.note || '',
        tels: props.tels || [],
        mails: props.mails || [],
        www: props.www || [],
        tags: props.tags || [],
        groups: props.groups || []
      };
    },
    fullname: function (c) {
      return c.firstname + ' ' + c.lastname;
    },
    fulladdress: function (c) {
      if (c.city) {
        return c.address + ' ' + c.postalCode + ' ' + c.city;
      } else {
        return '';
      }
    },
  };
  /*
  contact.Contact = function (props) {
    this.schema = 'contact';
    // TMP
    if (!props.key) {
      props.key = contact.Contact.key;
      contact.Contact.key = props.key + 1;
    }
    this.key = props.key;
    // End TMP
    var _populate = (function (k, fallback) {
      this[k] = props[k] ?props[k] : fallback;
    }).bind(this);
    this.firstname = props.firstname;
    this.lastname = props.lastname;
    ['address', 'postalCode', 'city', 'note'].forEach(function (k) {
      _populate(k, '');
    });
    ['tels', 'mails', 'www', 'groups', 'tags'].forEach(function (k) {
      _populate(k, []);
    });
    // Extra properties
    this.fullname = function () {
      return this.firstname + ' ' + this.lastname;
    };
    this.fulladdress = function () {
      if (this.city) {
        return this.address + ' ' + this.postalCode + ' ' + this.city;
      }
    };
  };
  contact.Contact.key = 0; // TMP
  */

  contact.data.items = [
    contact.model.create({
        firstname: 'Laurent',
        lastname: 'Costy',
        postalCode: '21000',
        city: 'Dijon',
        note: 'Délégué régional',
        groups: ['ffmjc', 'ffmjc-bourgogne', 'libre', 'libre-april'],
        tags: ['à rappeler']
    }),
    contact.model.create({
        firstname: 'Fabien',
        lastname: 'Bourgeois',
        address: '10bis rue Jangot',
        postalCode: '69003',
        city: 'Lyon',
        note: '<p>Fait partie d\'une coopérative d\'activités et d\'emplois.</p>',
        tels: [
          { label: 'pro', value: '0482531547', default: false },
          { label: 'mobile', value: '0652816984', default: true },
          { label: 'fax', value: '0482531565', default: false }
        ],
        mails: [
          { label: 'pro', value: 'fbourgeois@yaltik.com', default: true },
          { label: 'perso', value: 'fabien@yakulu.net', default: false },
          { label: 'jabber', value: 'fabien@yakulu.net', default: false }
        ],
        www: ['http://www.yaltik.com', 'http://yakulu.net'],
        groups: ['computer', 'computer-ssll', 'computer-ssll-yaltik', 'libre', 'libre-april', 'libre-aldil'],
        tags: ['freelance', 'ess', 'web']
    }),
    contact.model.create({
        firstname: 'Richard Matthew',
        lastname: 'Stallman',
        mails: [ { label: 'pro', value: 'rms@gnu.org', default: true } ],
        www: ['http://stallman.org'],
        groups: ['libre', 'libre-fsf'],
        tags: ['gnu', 'militant', 'à rappeler', 'anglophone'],
    }),
    contact.model.create({
        firstname: 'Linus',
        lastname: 'Torvalds',
        city: 'Portland',
        note: 'Concepteur originel du noyau Linux',
        www: ['http://torvalds-family.blogspot.com', 'http://www.cs.helsinki.fi/u/torvalds'],
        groups: ['libre'],
        tags: ['linux', 'anglophone', 'à rappeler']
    }),
    contact.model.create({
        firstname: 'Jean',
        lastname: 'Dupont',
        address: '19 rue de la Platitude',
        postalCode: '69001',
        city: 'Lyon',
        tags: ['militant', 'ess']
    })
  ];

  contact.modules.list = {
    controller: function () {
      golem.controller.call(this);
      var l = golem.utils.locale;
      var cmi = contact.data.menuItems;
      this.secondaryMenu.replace([
        cmi.list, cmi.add, cmi.tags
      ]);
      document.title = this.docTitle + l('CONTACTS_LIST');
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
      this.mainContent = (function () {
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
      this.contextMenuContent = (function () {
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
      return golem.view.call(this, ctrl);
    }
  };

  contact.modules.show = {
    controller: function () {
      var l = golem.utils.locale;
      golem.controller.call(this);
      var key = m.route.param('contactId');
      m.startComputation();
      golem.model.db.get(key, (function (err, res) {
        this.contact = res;
        document.title = this.docTitle + l('CONTACTS_DETAIL') +
          contact.model.fullname(this.contact);
        var cmi = contact.data.menuItems;
        ['show', 'edit', 'remove'].forEach((function (v) {
          cmi[v].url = cmi[v].baseUrl + '/' + this.contact._id;
        }).bind(this));
        this.secondaryMenu.replace([
          cmi.list, cmi.add, cmi.show, cmi.edit, cmi.remove
        ]);
        m.endComputation();
      }).bind(this));
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var c = ctrl.contact;
      var format = {
        default: function (def) {
          if (def) {
            return m('span', [
              m('i', {
                class: 'checkmark icon green',
                title: l('DEFAULT')
                }
              )
            ]);
          }
        },
        tels: function (item) {
          return m('li', [
            item.label + ' : ',
            m('a', { href: 'tel:' + item.value },
              item.value.match(/\d{2}/g).join('.')),
            format.default(item.default)
          ]);
        },
        mails: function (item) {
          return m('li', [
            item.label + ' : ',
            m('a', { href: 'mailto:' + item.value }, item.value),
            format.default(item.default)
          ]);
        },
        www: function (item) {
          return m('li', [ m('a', { href: item }, item) ]);
        }
      };
      var groupsBox = (function () {
        if (c.groups.length === 0) {
          return m('p', l('GROUPS_NONE'));
        } else {
          return m('p', [
            m('div', { class: 'ui green label'}, l('MENU_GROUPS')),
            m('ul', { class: 'ui horizontal bulleted list' }, c.groups.map(function (group) {
              return m('li', { class: 'item' }, group);
            }))
          ]);
        }
      }).call();
      var multiBox = function (items, header, formatFn) {
        if (items.length > 0) {
          return m('div', [
            m('div', { class: 'ui black label' }, header),
            m('ul', items.map(formatFn))
          ]);
        }
      };
      this.mainContent = m('section', { class: 'ui piled segment' }, [
        m('div', { class: 'ui floated right basic segment' },
          c.tags.map(function (tag) {
            return m('a', {
                class: 'ui small teal label golem-tag',
                href: '#/contact/list/filter/tag/' + tag,
                title: l('CONTACTS_BY_TAGS'),
                //config: m.route
              }, [
              m('i', { class: 'tag icon' }),
              tag
            ]);
          })
        ),
        m('h2', contact.model.fullname(c)),
        m('p', m.trust(c.note)),
        m('div', { class: 'ui two column grid' }, [
          m('div', { class: 'column' }, [
            m('p', [
              m('div', { class: 'ui label' }, l('CONTACT_DETAILS')),
              m('div', contact.model.fulladdress(c))
            ]),
            m('div', groupsBox)
          ]),
          m('div', { class: 'column' }, [
            m('p', [
              multiBox(c.tels, l('TELS'), format.tels),
              multiBox(c.mails, l('MAILS'), format.mails),
              multiBox(c.www, l('WWW'), format.www)
            ])
          ])
        ])
      ]);
      return golem.view.call(this, ctrl);
    }
  };

  contact.modules.form = {
    controller: function () {
      // Init
      var l = golem.utils.locale;
      golem.controller.call(this);
      // Menus
      var cmi = contact.data.menuItems;
      this.secondaryMenu.replace([ cmi.list, cmi.add ]);
      // Model
      var key = m.route.param('contactId');
      m.startComputation();
      contact.data.getTags((function () {
        golem.model.db.get(key, (function (err, res) {
          this.contact = res;
          if (!this.contact) {
            this.add = true;
            this.contact = contact.model.create({
              firstname: '',
              lastname: ''
            });
          } else {
            this.add = false;
          }
          // Widgets
          this.telsWidget = new form.multiFieldWidget.controller({
            label: l('TELS'),
            name: 'tels',
            maxlength: 10,
            size: 15,
            radioField: true,
            labelField: true,
            placeholder: l('TEL_PLACEHOLDER'),
            content: l('INFO_FORM_TELS'),
            current: this.contact.tels
          });
          this.mailsWidget = new form.multiFieldWidget.controller({
            type: 'email',
            label: l('MAILS'),
            name: 'mails',
            size: 25,
            radioField: true,
            labelField: true,
            placeholder: l('MAIL_PLACEHOLDER'),
            content: l('INFO_FORM_MAILS'),
            current: this.contact.mails
          });
          this.wwwWidget = new form.multiFieldWidget.controller({
            type: 'url',
            label: l('WWW'),
            name: 'www',
            placeholder: l('WWW_PLACEHOLDER'),
            content: l('INFO_FORM_WWW'),
            current: this.contact.www
          });
          this.tagWidget = new form.tagWidget.controller({
            name: 'tags',
            label: l('MENU_TAGS'),
            placeholder: l('TAGS_PLACEHOLDER'),
            content: l('INFO_FORM_TAGS'),
            size: 25,
            tags: contact.data.tags.map(function (tag) { return tag.key[1]; }),
            current: this.contact.tags
          });
          // Add or edit
          if (this.add) {
            document.title = this.docTitle + l('CONTACTS_NEW');
          } else {
            document.title = this.docTitle + l('CONTACTS_EDIT') +
              contact.model.fullname(this.contact);
            ['show', 'edit', 'remove'].forEach((function (v) {
              cmi[v].url = cmi[v].baseUrl + '/' + this.contact._id;
            }).bind(this));
            this.secondaryMenu.items.splice(2, 0,
              cmi.show, cmi.edit, cmi.remove);
          }
          m.endComputation();
        }).bind(this));
      }).bind(this));
      // Methods
      this.submit = (function (e) {
        e.preventDefault();
        var _submit = (function (verb) {
          golem.model.db[verb](this.contact, function (err, res) {
            golem.utils.sendNotification(
              l('SUCCESS'),
              { body: l('SUCCESS_UPDATE') },
              m.route.bind(null, '/contact/list')
            );
          });
        }).bind(this);
        var verb = this.contact_id ? 'put' : 'post';
        _submit(verb);
      }).bind(this);
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      var c = ctrl.contact;
      var h2 = ctrl.add ? l('CONTACTS_NEW') : l('CONTACTS_EDIT') + ' ' + contact.model.fullname(c);
      this.mainContent = m('section', { class: 'ui piled segment' }, [
        m('h2', h2),
        m('form', {
          id: 'contact-form',
          class: 'ui small form',
          onsubmit: ctrl.submit.bind(ctrl) }, [
          m('div', { class: 'two fields' }, [
            form.textHelper({
              name: 'lastname',
              label: l('LASTNAME'),
              minlength: 2,
              maxlength: 100,
              required: true,
              value: c.lastname,
              onchange: m.withAttr('value',
                function (v) { c.lastname = v; })
            }),
            form.textHelper({
              name: 'firstname',
              label: l('FIRSTNAME'),
              minlength: 2,
              maxlength: 100,
              required: true,
              value: c.firstname,
              onchange: m.withAttr('value',
                function (v) { c.firstname = v; })
            })
          ]),
          m('div', { class: 'three fields' }, [
            form.textHelper({
              name: 'address',
              label: l('ADDRESS'),
              value: c.address,
              onchange: m.withAttr('value',
                function (v) { c.address = v; })
            }),
            form.textHelper({
              name: 'postalCode',
              label: l('POSTAL_CODE'),
              value: c.postalCode,
              onchange: m.withAttr('value',
                function (v) { c.postalCode = v; })
            }),
            form.textHelper({
              name: 'city',
              label: l('CITY'),
              value: c.city,
              onchange: m.withAttr('value',
                function (v) { c.city = v; })
            })
          ]),
          m('div', [
            new form.multiFieldWidget.view(ctrl.telsWidget),
            new form.multiFieldWidget.view(ctrl.mailsWidget)
          ]),
          m('div', { class: 'two fields' }, [
            new form.multiFieldWidget.view(ctrl.wwwWidget),
            new form.tagWidget.view(ctrl.tagWidget),
          ]),
          m('div', { class: 'field' }, [
            m('label', { for: 'note' }, l('NOTE')),
            m('textarea', {
                name: 'note',
                onchange: m.withAttr('value',
                  function (v) { c.note = v; })
              }, c.note)
          ]),
          m('input', {
              id: 'contact-submit',
              class:'ui teal submit button',
              type: 'submit',
              form: 'contact-form',
              value: ctrl.add ? l('SAVE') : l('UPDATE')
          }),
          m('button', {
              name: 'cancel',
              class: 'ui button',
              type: 'button',
              onclick: function () { 
                window.location.hash = '#/contact/list';
              }
            }, l('CANCEL'))
        ])
      ]);
      this.contextMenuContent = m('nav', [
        m('menu', { class: 'ui buttons fixed-right' }, [
          m('input', {
            class: 'ui fluid teal submit button',
            type: 'submit',
            value: ctrl.add ? l('SAVE') : l('UPDATE'),
            // FIXME : here's a hack, to fix properly
            onclick: function () {
              document.getElementById('contact-submit').click();
            }
          }),
          m('div', {
            role: 'button',
          class: 'ui fluid button',
          onclick: function (e) { window.location = '#/contact/list'; }
          }, l('CANCEL'))
        ])
      ]);
      return golem.view.call(this, ctrl);
    }
  };

  contact.modules.remove = {
    controller: function () {
      var l = golem.utils.locale;
      golem.controller.call(this);
      var key = m.route.param('contactId');
      m.startComputation();
      golem.model.db.get(key, (function (err, res) {
        this.contact = res;
        document.title = this.docTitle + l('CONTACTS_REMOVE') +
          contact.model.fullname(this.contact);
        this.removeModalCtrl = new widgets.modal.controller({
          active: true,
          title: l('SURE'),
          content: l('CONTACTS_REMOVE_CONFIRM_MSG'),
          acceptFn: (function () {
            golem.model.db.remove(this.contact, function (err, res) {
              m.route('/contact/list');
            });
          }).bind(this),
          cancelFn: (function () {
            this.removeModalCtrl.toggle();
            m.route('/contact/list');
          }).bind(this)
        });
        m.endComputation();
      }).bind(this));
    },
    view: function (ctrl) {
      this.mainContent = new widgets.modal.view(ctrl.removeModalCtrl);
      return golem.view.call(this, ctrl);
    }
  };

  contact.modules.tags = {
    controller: function () {
      var l = golem.utils.locale;
      golem.controller.call(this);
      var cmi = contact.data.menuItems;
      this.secondaryMenu.replace([ cmi.list, cmi.add, cmi.tags ]);
      document.title = this.docTitle + l('TAGS_MANAGEMENT');
      this.tags = [];
      m.startComputation();
      contact.data.getTags((function (err, res) {
        this.tags = res.rows.map(function (tag) {
          return tag.key[1];
        });
        m.endComputation();
      }).bind(this));
      this._updateTag = (function (input, removal) {
        m.startComputation();
        var oldVal = input.getAttribute('data-value');
        var newVal;
        if (removal) {
          newVal = false;
        } else {
          newVal = input.value;
          if (newVal.length === 0) {
            input.value = oldVal;
            return;
          }
        }
        golem.model.db.query('tags/count', {
          reduce: false,
          key: ['contact', oldVal],
          include_docs: true
        }, (function (err, res) {
          var docs = [];
          res.rows.forEach(function (row) {
            var idx = row.doc.tags.indexOf(oldVal);
            if (newVal) {
              row.doc.tags[idx] = newVal;
            } else {
              row.doc.tags.splice(idx, 1);
            }
            docs.push(row.doc);
          });
          golem.model.db.bulkDocs(docs, (function (err, res) {
            golem.utils.sendNotification(
              l('SUCCESS'),
              { body: l('SUCCESS_UPDATE') },
              (function () {
                if (!newVal) {
                  var tagsIdx = this.tags.indexOf(oldVal);
                  this.tags.splice(tagsIdx, 1); 
                  this.removeModalCtrl.toggle();
                }
                m.endComputation();
              }).bind(this)
            );
          }).bind(this));
        }).bind(this));
      }).bind(this);
      this.updateTagFromClick = (function (e) {
        var input = e.target.parentElement.parentElement.children[0].children[0];
        this._updateTag(input);
      }).bind(this);
      var input = null;
      this.removeModalCtrl = new widgets.modal.controller({
        title: l('SURE'),
        content: l('TAGS_DELETE_CONFIRM_MSG'),
        acceptFn: (function () {
          this._updateTag(input, true);
        }).bind(this)
      });
      this.removeTag = (function (e) {
        input = e.target.parentElement.parentElement.children[0].children[0];
        this.removeModalCtrl.toggle();
      }).bind(this);
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      this.mainContent = m('section', [
        m('h2', l('TAGS_MANAGEMENT')),
        m('div', { class: 'ui grid' }, [
          m('div', { class: 'ten wide column'}, [
            m('ul', { class: 'ui bulleted list' }, ctrl.tags.map(function (tag) {
              return m('li', { class: 'item golem-tag' }, [
                m('span', { class: 'ui small input' }, [
                  m('input', {
                    size: 10,
                    value: tag,
                    'data-value': tag
                  })
                ]),
                m('span', { class: 'ui buttons' }, [
                  m('button', {
                    type:'button',
                    class: 'ui tiny blue button',
                    onclick: ctrl.updateTagFromClick
                  }, l('RENAME')),
                  m('span.or'),
                  m('button', {
                    type:'button',
                    class: 'ui tiny red button',
                    onclick: ctrl.removeTag
                  }, l('DELETE'))
                ])
              ]);
            }))
          ]),
          m('div', { class: 'six wide column' }, [
            m('div', { class: 'ui purple inverted segment' }, [
              m('h3', [
                m('i', { class: 'info icon' }),
                m('span', l('HELP'))
              ]),
              m('p', m.trust(l('TAGS_MANAGEMENT_HELP_MSG')))
            ])
          ])
        ]),
        new widgets.modal.view(ctrl.removeModalCtrl)
      ]);
      return golem.view.call(this, ctrl);
    }
  };

  contact.data.getTags = function (callback) {
    golem.model.db.query(
      'tags/count',
      {
        group: true,
        startKey: ['contact'],
        endKey: ['contact', {}]
      },
      function (err, res) {
        contact.data.tags = res.rows;
        contact.data.tags.sort(function (a, b) {
          // Sort by value DESC
          return b.value - a.value;
        });
        callback(err, res);
      }
    );
  };
  // TODO : remove & edit tag (contenteditable on click ?)
  contact.data.tags = [];
  /*
  // FIXME: falsy, don't update in case of removes
  contact.tags = (function () {
    var _tags = {};
    contact.data.items.forEach(function (c) {
      c.tags.forEach(function (tag) {
        if (!_tags[tag]) {
          _tags[tag] = 1;
        } else {
          _tags[tag] += 1;
        }
      });
    });
    return _tags;
  }).call();
  */

  contact.data.labels = (function () {
    var _labels = { tels: [], mails: [] };
    contact.data.items.forEach(function (c) {
      c.tels.forEach(function (tel) {
        if (_labels.tels.indexOf(tel.label) === -1) {
        _labels.tels.push(tel.label);
        }
      });
      c.mails.forEach(function (mail) {
        if (_labels.mails.indexOf(mail.label) === -1) {
        _labels.mails.push(mail.label);
        }
      });
    });
    return _labels;
  }).call();
  // End of FIXME

  /*var menus
  window.onhashchange = function () {
    menus.foreach(function (m) {
      m.render();
    });
  };*/

  window.onload = function () {
    // Database
    var db = golem.model.db;
    // TMP DEV : Repopulate at launch...
    //db.destroy(function () {
    //  golem.model.db = new PouchDB('golem');
    //  db = golem.model.db;
      window.db = db;
      db.allDocs(function (err, response) {
        if (err || response.rows.length === 0) {
          db.bulkDocs(contact.data.items, function (err, response) {
            var gmq = golem.model.queries;
            var queries = [gmq.all, gmq.tags];
            db.bulkDocs(queries, function (err, response) {
              init();
            });
          });
        } else {
          init();
        }
      });
    //});
    var init = function () {
      // Routing
      m.route.mode = 'hash';
      m.route(document.body, '/', {
        '/': golem,
        '/contact': contact.modules.list,
        '/contact/list': contact.modules.list,
        '/contact/list/filter/tag/:tag': contact.modules.list,
        '/contact/list/page/:page': contact.modules.list,
        '/contact/tags': contact.modules.tags,
        '/contact/show/:contactId': contact.modules.show,
        '/contact/add': contact.modules.form,
        '/contact/edit/:contactId': contact.modules.form,
        '/contact/remove/:contactId': contact.modules.remove
      });
    };
  };
}).call(this);
