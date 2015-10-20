PouchDb = require 'pouchdb'
db = new PouchDb 'golemdata'
tags =
  _id: '_design/tags'
  views:
    count:
      map: ((doc) ->
        emitProp = (schema, prop) ->
          schema = schema or doc.schema
          prop = prop or 'tags'
          i = 0
          l = doc[prop].length

          while i < l
            emit [
              schema
              doc[prop][i]
              doc.season
            ]
            i++
          return

        emitProp()  if doc.tags
        emitProp 'memberskills', 'skills'  if (doc.schema is 'member') and doc.skills
        return
      ).toString()
      reduce: '_count'

db.get '_design/tags', (err, doc) ->
  tags._rev = doc._rev
  db.put tags, (err, doc) ->
    console.log arguments
