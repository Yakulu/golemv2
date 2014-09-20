# GOLEM Database

## Initialization

The database server is located at the same URL as the main NodeJS server. The
database is named `golemdata`.

    db = new PouchDB "#{location.protocol}//#{location.host}/db/golemdata"

## Queries

The design doc `all` is used for a global `bySchema` view, aimed to retrieve all
the documents, ranged by their `schema` field and their `creationDate`.

    all =
      _id: '_design/all'
      views:
        bySchema:
          map: ((doc) ->
            emit([doc.schema, doc.creationDate], null) if doc.schema
          ).toString()
 
 The design doc `members` contains all views that have as goal to get members, 
 for instance only from a given activity. It relies on view collation.

    members =
      _id: '_design/members'
      views:
        byActivity:
          map: ((doc) ->
            if doc.schema and doc.schema is 'member'
              emit([activity, doc.schema], null) for activity in doc.activities
          ).toString()

`tags` design doc gives all tags by schema and counts them, thanks to the reduce
function. It alsa handles members `skills`. As others, view collation is used
too.

    tags =
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

`labels` design doc is used to get labels for rich fields, using a triplet key
collation. As for `tags`, the documents are grouped by a reduce function,
`count`.

    labels =
      _id: '_design/labels'
      views:
        all:
          map: ((doc) ->
            emitProp = (type, prop, coll) ->
              emit([type, item[prop]]) for item in coll
            emitProp('tels', 'label', doc.tels) if doc.tels
            emitProp('mails', 'label', doc.mails) if doc.mails
          ).toString()
          reduce: '_count'



## Public API

    golem.db = db
