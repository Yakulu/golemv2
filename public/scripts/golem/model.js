// Generated by CoffeeScript 1.8.0
(function() {
  golem.model = {
    getBySchema: function(schema, callback) {
      golem.model.db.query('all/bySchema', {
        startkey: [schema],
        endkey: [schema, {}],
        include_docs: true
      }, callback);
    },
    labels: {
      mails: [],
      tels: []
    },
    getTags: function(type, module, field, callback) {
      return golem.model.db.query('tags/count', {
        group: true,
        startkey: [type],
        endkey: [type, {}]
      }, function(err, res) {
        if (err) {
          golem.notifications.helpers.errorUnexpected({
            body: err
          });
        } else {
          golem.module[module].data[field] = res.rows;
          golem.module[module].data[field].sort(function(a, b) {
            return b.value - a.value;
          });
        }
        return callback(err, res);
      });
    },
    getLabels: function(type, callback) {
      if (type == null) {
        type = 'tels';
      }
      return golem.model.db.query('labels/all', {
        group: true,
        startkey: [type],
        endkey: [type, {}]
      }, function(err, res) {
        if (err) {
          golem.notifications.helpers.errorUnexpected({
            body: err
          });
        } else {
          golem.model.labels[type] = res.rows;
        }
        return callback(err, res);
      });
    },
    getMembersByTag: function(tag, callback) {
      return golem.model.db.query('tags/count', {
        reduce: false,
        key: ['member', tag],
        include_docs: true
      }, callback);
    },
    getMembersFromActivity: function(activityId, callback) {
      if (!activityId) {
        return golem.model.db.query('members/byActivity', callback);
      } else {
        return golem.model.db.query('members/byActivity', {
          key: [activityId, 'member'],
          include_docs: true
        }, callback);
      }
    },
    db: new PouchDB("" + window.location.protocol + "//" + window.location.host + "/db/golemdata"),
    queries: {
      all: {
        _id: '_design/all',
        views: {
          bySchema: {
            map: (function(doc) {
              if (doc.schema) {
                return emit([doc.schema, doc.creationDate], null);
              }
            }).toString()
          }
        }
      },
      members: {
        _id: '_design/members',
        views: {
          byActivity: {
            map: (function(doc) {
              var activity, _i, _len, _ref, _results;
              if (doc.schema && doc.schema === 'member') {
                _ref = doc.activities;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  activity = _ref[_i];
                  _results.push(emit([activity, doc.schema], null));
                }
                return _results;
              }
            }).toString()
          }
        }
      },
      tags: {
        _id: '_design/tags',
        views: {
          count: {
            map: (function(doc) {
              var emitProp;
              emitProp = function(schema, prop) {
                var p, _i, _len, _ref, _results;
                if (schema == null) {
                  schema = doc.schema;
                }
                if (prop == null) {
                  prop = 'tags';
                }
                _ref = doc[prop];
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  p = _ref[_i];
                  _results.push(emit([schema, p]));
                }
                return _results;
              };
              if (doc.tags) {
                emitProp();
              }
              if ((doc.schema === 'member') && doc.skills) {
                return emitProp('memberskills', 'skills');
              }
            }).toString(),
            reduce: '_count'
          }
        }
      },
      labels: {
        _id: '_design/labels',
        views: {
          all: {
            map: (function(doc) {
              var emitProp;
              emitProp = function(type, prop, coll) {
                var item, _i, _len, _results;
                _results = [];
                for (_i = 0, _len = coll.length; _i < _len; _i++) {
                  item = coll[_i];
                  _results.push(emit([type(item[prop])]));
                }
                return _results;
              };
              if (doc.tels) {
                emitProp('tels', 'label', doc.tels);
              }
              if (doc.mails) {
                return emitProp('mails', 'label', doc.mails);
              }
            }).toString(),
            reduce: '_count'
          }
        }
      }
    }
  };

}).call(this);

//# sourceMappingURL=model.js.map
