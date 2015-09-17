module = golem.module.activity
l = golem.config.locale
acceptFn = (activity) ->
    delete @item._id
    delete @item._rev
    @item.creationDate = Date.now()
    @item.season = 2015
    golem.model.db.post @item, (err, res) =>
      if err
        golem.widgets.common.notifications.error
          body: '<em>' + err + '</em><br>' + l.ERROR_UPDATE,
          m.route.bind null, "/activity/list"
      else
        golem.config.season = 2015
        golem.widgets.common.notifications.success
          body: l.SUCCESS_UPDATE,
          m.route.bind @, "/activity/show/#{res.id}"

module.component.duplicate = golem.component.remove
  module: module
  class: golem.Activity,
  key: 'activityId'
  acceptFn: acceptFn
  nameFn: (item) -> item.label
  confirm: 'ACTIVITIES_DUPLICATE_CONFIRM_MSG'
  route: '/activity/list'
