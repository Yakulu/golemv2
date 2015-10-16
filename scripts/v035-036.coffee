PouchDb = require 'pouchdb'
db = new PouchDb 'golemdata'

db.allDocs { include_docs: true }, (err, resp) ->
  console.log err if err
  m = (r.doc for r in resp.rows when r.doc.schema is  'member' and r.doc.season is 2015)
  for doc in m
    doc.tags = []
  db.bulkDocs m, (err, resp) ->
    console.log err if err
    console.log 'migration successfully done'
