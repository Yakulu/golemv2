(function () {
  golem.model = {
    labels: { mails: [], tels: [] },
    getTags: function (type, module, field, callback) {
      golem.model.db.query(
        'tags/count',
        {
          group: true,
          startkey: [type],
          endkey: [type, {}]
        },
        function (err, res) {
          golem.module[module].data[field] = res.rows;
          golem.module[module].data[field].sort(function (a, b) {
            // Sort by value DESC
            return b.value - a.value;
          });
          callback(err, res);
        }
      );
    },
    getLabels: function (type, callback) {
      type = type || 'tels';
      golem.model.db.query(
        'labels/all',
        {
          group: true,
          startkey: [type],
          endkey: [type, {}]
        },
        function (err, res) {
          golem.model.labels[type] = res.rows;
          callback(err, res);
        }
      );
    },
    title: function (suffix) {
      return golem.utils.locale('TITLE') + ' - ' + suffix;
    },
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
      },
      labels: {
        _id: '_design/labels',
        views: {
          all: {
            map: function (doc) {
              var emitProp = function (type, prop, coll) {
                for (var i = 0, l = coll.length; i < l; i++) {
                  //emit([type, coll[i][prop]], null);
                  emit([type, coll[i][prop]]);
                }
              };
              if (doc.tels) { emitProp('tels', 'label', doc.tels); }
              if (doc.mails) { emitProp('mails', 'label', doc.mails); }
            }.toString(), reduce: '_count'
          }
        }
      }
    }
  };
}).call(this);
