true
express = require('express')
app = express()
PouchDb = require('pouchdb')
app.use '/db', require('express-pouchdb')(PouchDb)
app.use express.static('public')
db = new PouchDb('golemdata')
dbQueries =
  all:
    _id: '_design/all'
    views:
      bySchema:
        map: ((doc) ->
          if doc.schema
            emit [
              doc.schema
              doc.creationDate
            ], null
          return
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

  labels:
    _id: '_design/labels'
    views:
      all:
        
        #emit([type, coll[i][prop]], null);
        map: ((doc) ->
          emitProp = (type, prop, coll) ->
            i = 0
            l = coll.length

            while i < l
              emit [
                type
                coll[i][prop]
              ]
              i++
            return

          emitProp 'tels', 'label', doc.tels  if doc.tels
          emitProp 'mails', 'label', doc.mails  if doc.mails
          return
        ).toString()
        reduce: '_count'


# TMP?
db.allDocs (err, response) ->
  if err or response.rows.length is 0
    queries = [
      dbQueries.all
      dbQueries.tags
      dbQueries.labels
      dbQueries.members
    ]
    db.bulkDocs queries, (err, response) ->
      console.log 'db initialized'
      return

  return

server = app.listen(8042, ->
)
