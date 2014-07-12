(function () {
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
}).call(this);
