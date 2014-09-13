(function () {
  // TODO : integrity checks with members...
  var module = golem.module.activity;
  var l = golem.config.locale;
  var acceptFn = function (activity) {
    golem.model.getMembersFromActivity(activity._id, function (err, res) {
      if (err) {
        golem.notifications.helpers.errorUnexpected({ body: err });
      } else {
        var callback = function (err, res) {
          if (err) {
            golem.notifications.helpers.errorUnexpected({ body: err });
          } else {
            golem.notifications.helpers.success({ body: l.SUCCESS_UPDATE });
            m.route('/activity/list');
          }
        };
        if (res.rows.length > 0) {
          var docs = res.rows.map(function (r) {
            var idx = r.doc.activities.indexOf(activity._id);
            r.doc.activities.splice(idx, 1);
            return r.doc;
          });
          activity._deleted = true;
          docs.push(activity);
          console.log(docs);
          golem.model.db.bulkDocs(docs, callback);
        } else {
          golem.model.db.remove(activity, callback);
        }
      }
    });
  };
  module.component.remove = golem.component.remove({
    module: module,
    key: 'activityId',
    acceptFn: acceptFn,
    nameFn: function (item ) { return item.label; },
    confirm: 'ACTIVITIES_REMOVE_CONFIRM_MSG',
    route: '/activity/list'
  });
}).call(this);
