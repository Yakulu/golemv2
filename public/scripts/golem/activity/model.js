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
    },
    fullLabel: function (a) {
      if (a.code) { return a.code + ' ' + a.label; }
      return a.label;
    }
    // TODO : full, remainingPlaces, number of subscribers etc
  };
}).call(this);
