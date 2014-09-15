module = golem.module.activity
l = golem.config.locale
acceptFn = (activity) ->
  golem.model.getMembersFromActivity activity._id, (err, res) ->
    if err
      golem.widgets.common.notifications.errorUnexpected body: err
    else
      callback = (err, res) ->
        if err
          golem.widgets.common.notifications.errorUnexpected body: err
        else
          golem.widgets.common.notifications.success body: l.SUCCESS_UPDATE
          m.route '/activity/list'
      if res.rows.length > 0
        docs = res.rows.map (r) ->
          idx = r.doc.activities.indexOf activity._id
          r.doc.activities.splice idx, 1
          r.doc
        activity._deleted = true
        docs.push activity
        golem.model.db.bulkDocs docs, callback
      else
        golem.model.db.remove activity, callback
  return

module.component.remove = golem.component.remove
  module: module
  class: golem.Activity,
  key: 'activityId'
  acceptFn: acceptFn
  nameFn: (item) -> item.label
  confirm: 'ACTIVITIES_REMOVE_CONFIRM_MSG'
  route: '/activity/list'
