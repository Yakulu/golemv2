var express = require('express');
var app = express();
var PouchDb = require('pouchdb');

app.use('/db', require('express-pouchdb')(PouchDb));
app.use(express.static('public'));

var db = new PouchDb('golemdata');

var dbQueries = {
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
};


// TMP?
db.allDocs(function (err, response) {
  if (err || response.rows.length === 0) {
    var queries = [dbQueries.all, dbQueries.tags, dbQueries.labels];
    db.bulkDocs(queries, function (err, response) {
      console.log('db initialized');
    });
  }
});

var server = app.listen(8043, function () {});
