# Activity removal

The activity deletion takes the document identifier as standalone argument. It
launches the common remove component with a configuration object, used to
display the modal. It's automatically runned on the initialization.

    ns = golem.module.activity
    notif = golem.common.notification

    remove = {}

    remove.launch = (id) ->
      golem.common.remove
        model: ns.model.activity
        id: id
        approveCb: remove.approveCb
        nameField: 'label'
        content: 'ACTIVITIES_REMOVE_CONFIRM_MSG'
        route: '#/activity'

`\_removeCb` is a private function that throws an unexpected error if there is
one and a successfull notification in the other case, always redirecting to the
activity list. It takes `err` and `res` from database as arguments.

    remove._removeCb = (err, res) ->
      if err
        notif.send(notif.unexpected content: err)
      else
        notif.send(notif.success content: L('SUCCESS_UPDATE'))
      window.location.hash = '#/activity'

`approveCb` replaces the standard remove approve callback. It takes care of
subscribed members : it will unsubscribe every member on removal and makes the
whole request as a BULK transaction. If no member is linked, it will just uses
the standard removal for the activity.

    remove.approveCb = (activity) ->
      golem.model.getMembersFromActivity activity._id.get(), (err, res) ->
        if err
          notif.send(notif.unexpected content: err)
        else
          if res.rows.length > 0
            docs = res.rows.map (r) ->
              r.doc.activities.remove(activity._id.get())
              r.doc
            activity._deleted = true
            docs.push rx.unlift(activity)
            golem.db.bulkDocs docs, remove._removeCb
          else
            golem.db.remove rx.unlift(activity), remove._removeCb


## Public API

    ns.remove = remove
