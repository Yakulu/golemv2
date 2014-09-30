# Activity removal

The activity deletion takes the document identifier as standalone argument. It
takes care of subscribed members : it will unsubscribe every member on removal
and makes the whole request as a BULK transaction.  If no member is linked, it
will just uses the standard removal for the activity.

    ns = golem.module.activity
    notif = golem.component.notification

    class Remove

      constructor: (@id) ->
        @approveCb = (activity) ->
          golem.model.getMembersFromActivity activity._id.get(), (err, res) ->
            if err
              notif.send(notif.unexpected content: err)
            else
              callback = (err, res) ->
                if err
                  notif.send(notif.unexpected content: err)
                else
                  notif.send(notif.success content: L('SUCCESS_UPDATE'))
                window.location.hash = '#/activity'
              if res.rows.length > 0
                docs = res.rows.map (r) ->
                  r.doc.activities.remove(activity._id.get())
                  r.doc
                activity._deleted = true
                docs.push rx.unlift(activity)
                golem.db.bulkDocs docs, callback
              else
                golem.db.remove rx.unlift(activity), callback
        @launch()

`launch` is just used to display the modal with correct configuration. It's
automatically runned on the initialization.

      launch: =>
        golem.component.remove
          model: ns.model.activity
          id: @id
          approveCb: @approveCb
          nameField: 'label'
          content: 'ACTIVITIES_REMOVE_CONFIRM_MSG'
          route: '#/activity'

## Public API

    ns.component.Remove = Remove
