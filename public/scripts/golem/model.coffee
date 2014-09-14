golem.model =
  getBySchema: (schema, callback) ->
    golem.model.db.query 'all/bySchema',
      startkey: [schema]
      endkey: [schema, {}]
      include_docs: true
    , callback
    return

  labels:
    mails: []
    tels: []

  getTags: (type, module, field, callback) ->
    golem.model.db.query 'tags/count',
      group: true
      startkey: [type]
      endkey: [type, {}]
    , (err, res) ->
      if err
        golem.widgets.common.notifications.errorUnexpected body: err
      else
        golem.module[module].data[field] = res.rows
        # Sort by value DESC
        golem.module[module].data[field].sort (a, b) -> b.value - a.value
      callback err, res

  getLabels: (type, callback) ->
    type ?= 'tels'
    golem.model.db.query 'labels/all',
      group: true
      startkey: [type]
      endkey: [type, {}]
    , (err, res) ->
      if err
        golem.widgets.common.notifications.errorUnexpected body: err
      else
        golem.model.labels[type] = res.rows
      callback err, res

  getMembersByTag: (tag, callback) ->
    golem.model.db.query 'tags/count',
      reduce: false
      key: ['member', tag]
      include_docs: true
    , callback

  getMembersFromActivity: (activityId, callback) ->
    unless activityId
      golem.model.db.query 'members/byActivity', callback
    else
      golem.model.db.query 'members/byActivity',
        key: [activityId, 'member']
        include_docs: true
      , callback

  db: new PouchDB "#{location.protocol}//#{location.host}/db/golemdata"
  queries:
    all:
      _id: '_design/all'
      views:
        bySchema:
          map: ((doc) ->
            emit([doc.schema, doc.creationDate], null) if doc.schema
          ).toString()

    members:
      _id: '_design/members'
      views:
        byActivity:
          map: ((doc) ->
            if doc.schema and doc.schema is 'member'
              emit([activity, doc.schema], null) for activity in doc.activities
          ).toString()

    tags:
      _id: '_design/tags'
      views:
        count:
          map: ((doc) ->
            emitProp = (schema, prop) ->
              schema ?= doc.schema
              prop ?= 'tags'
              emit([schema, p]) for p in doc[prop]

            emitProp() if doc.tags
            if (doc.schema is 'member') and doc.skills
              emitProp('memberskills', 'skills')
          ).toString()
          reduce: '_count'

    labels:
      _id: '_design/labels'
      views:
        all:
          map: ((doc) ->
            emitProp = (type, prop, coll) ->
              emit([type item[prop]]) for item in coll

            emitProp('tels', 'label', doc.tels) if doc.tels
            emitProp('mails', 'label', doc.mails) if doc.mails
          ).toString()
          reduce: '_count'
