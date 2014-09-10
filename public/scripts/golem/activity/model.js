(function () {
  var gm = golem.module;
  gm.activity.model = {
    create: function (props) {
      props = props || {};
      return {
        schema: 'activity',
        creationDate: Date.now(),
        label: props.label || '',
        code: props.code || '',
        timeSlot: props.timeSlot || '',
        monitor: props.monitor || '',
        places: props.places || null,
        note: props.note || ''
      };
    }
    // TODO : full, remainingPlaces, number of subscribers etc
  };
}).call(this);
