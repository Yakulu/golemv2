(function () {
  var l = golem.utils.locale;
  var menus = golem.menus;
  var contact = golem.module.contact;
  contact.data = {};

  // Local data (ATM)
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

  // Menu Items
  contact.data.menuItems = {
    list: new menus.Item(l('MENU_LIST'), '/contact/list', 'list'),
    add: new menus.Item(l('MENU_NEW'), '/contact/add', 'add sign'),
    //groups: new menus.Item(l('MENU_GROUPS'), '/contact/groups', 'users'),
    tags: new menus.Item(l('MENU_TAGS'), '/contact/tags', 'tags'),
    show: new menus.Item(l('VIEW'), '/contact/show', 'search'),
    edit: new menus.Item(l('EDIT'), '/contact/edit', 'edit'),
    remove: new menus.Item(l('DELETE'), '/contact/remove', 'remove')
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
  contact.data.tags = [];

  // TODO: make it like tags : from database
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
}).call(this);
