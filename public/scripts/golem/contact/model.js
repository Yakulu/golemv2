(function () {
  golem.module.contact.model = {
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
}).call(this);
