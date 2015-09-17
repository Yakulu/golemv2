PouchDb = require 'pouchdb'
db = new PouchDb 'golemdata'

db.allDocs { include_docs: true }, (err, resp) ->
  console.log err if err
  ma = (r.doc for r in resp.rows when r.doc.schema in [ 'member', 'activity' ])
  for doc in ma
    doc.season = 2014
  db.bulkDocs ma, (err, resp) ->
    console.log err if err
    console.log 'migraton successfully done'
