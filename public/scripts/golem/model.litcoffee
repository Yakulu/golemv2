# GOLEM Model

## getBySchema

This helper returns all the documents, data included, from a given `schema`. A
`callback` function must be passed as second argument and will be executed
after the request has ended. This function will take an eventual error and the
results.

    getBySchema = (schema, callback) ->
      golem.db.query 'all/bySchema',
        startkey: [schema]
        endkey: [schema, {}]
        include_docs: true
      , callback
      return

## getTags

`getTags` returns tags or labels, according to the `field` argument by `type`,
grouped with the `count` function and takes a mandatory callback function, as
for `getBySchema`. `getTags` sends an `Unexpected` error if there is one.
Otherwise, it sorts results by DESC if `tags` are aksed, thanks to the value
field.

    getTags = (field, type, callback) ->
      ddoc = if field is 'tags' then 'tags/count' else 'labels/all'
      golem.db.query ddoc,
        group: true
        startkey: [type]
        endkey: [type, {}]
      , (err, res) ->
        if err
          new golem.component.common.notifications.Unexpected(body: err).send()
        else
          if field is 'tags'
            res.rows.sort (a, b) -> b.value - a.value
        callback err, res

## Getting Members from Activity

As named, this function helps retieving all documents with `schema` 'member'
when they are linked to a given `activity`. If no `activityId` is fixed, it
returns all members and all activities, without including the docs but allowing
things like global counts for all activities. The callback function iis
executed after the resukts are completed.

    getMembersFromActivity = (activityId, callback) ->
      unless activityId
        golem.db.query 'members/byActivity', callback
      else
        golem.db.query 'members/byActivity',
          key: [activityId, 'member']
          include_docs: true
        , callback

## Doc

`Doc` represents a document. It transforms all items from the database record,
given with the required argument, to members of the class, avoiding the
expensive validation.

    class golem.Doc
      constructor: (props) ->
        @[k] = v for k, v of props if props
        rx.lift @

## Public API

    golem.model =
      getBySchema: getBySchema
      getTags: getTags
      getMembersFromActivity: getMembersFromActivity
      Doc: golem.Doc
