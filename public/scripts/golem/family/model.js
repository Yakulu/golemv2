(function () {
  var gm = golem.module;
  gm.family.model = {
    create: function (props) {
      return {
        schema: 'family',
        creationDate: Date.now(),
        lastname: props.lastname || '',
        address: props.address || '',
        postalCode: props.postalCode || '',
        city: props.city || '',
        note: props.note || '',
        tels: props.tels || [],
        mails: props.mails || [],
        www: props.www || [],
        movements: props.movements || []
      };
    }
  };
}).call(this);
