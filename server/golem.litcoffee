# Main Server File

Standalone ATOM

## Dependencies

    express = require 'express'
    app = express()
    PouchDb = require 'pouchdb'

## Express App Configuration

ATM we use express-pouchdb application and mounts it to the _db_ path.
We alo need static file serving the _public_ directory.

    app.use '/db', require('express-pouchdb')(PouchDb)
    app.use express.static('public')

## Database

The database server is local via PouchDb and LevelUp. The database name is
`golemdata`.

    db = new PouchDb 'golemdata'

### Db queries

    dbQueries = {}
    dbMapFns = {}

The design doc `all` is used for a global `bySchema` view, aimed to retrieve all
the documents, ranged by their `schema` field and their `creationDate`.

    dbMapFns.allBySchema = (doc) ->
      emit [doc.schema, doc.creationDate], null if doc.schema

    dbQueries.all =
      _id: '_design/all'
      views:
        bySchema:
          map: dbMapFns.allBySchema.toString()

 The design doc `members` contains all views that have as goal to get members, 
 for instance only from a given activity. It relies on view collation.

    dbMapFns.membersByActivity = (doc) ->
      if doc.schema and doc.schema is 'member'
        emit [activity, doc.schema], null for activity in doc.activities

    dbQueries.members =
      _id: '_design/members'
      views:
        byActivity:
          map: dbMapFns.membersByActivity.toString()

`tags` design doc gives all tags by schema and counts them, thanks to the reduce
function. It alsa handles members `skills`. As others, view collation is used
too.

    dbMapFns.tagsCount = (doc) ->
      emitProp = (schema, prop) ->
        schema ?= doc.schema
        prop ?= 'tags'
        emit([schema, p]) for p in doc[prop]
      emitProp() if doc.tags
      if (doc.schema is 'member') and doc.skills
        emitProp 'memberskills', 'skills'

    dbQueries.tags =
      _id: '_design/tags'
      views:
        count:
          map: dbMapFns.tagsCount.toString()
          reduce: '_count'

`labels` design doc is used to get labels for rich fields, using a triplet key
collation. As for `tags`, the documents are grouped by a reduce function,
`count`.

    dbMapFns.labelsAll = (doc) ->
      emitProp = (type, prop, coll) ->
        emit [type, item[prop]] for item in coll
      emitProp 'tels', 'label', doc.tels if doc.tels
      emitProp 'mails', 'label', doc.mails if doc.mails

    dbQueries.labels =
      _id: '_design/labels'
      views:
        all:
          map: dbMapFns.labelsAll.toString()
          reduce: '_count'

### Views Initialization

If the database is empty, we push the views just defined.

    db.allDocs (err, res) ->
      if err or res.rows.length is 0
        queries = (v for k, v of dbQueries)
        db.bulkDocs queries, (err, res) ->
          if (err)
            console.log "Error : #{err}"
          else
            console.log 'db initialized'

# App running

    app.listen 8046, ->
