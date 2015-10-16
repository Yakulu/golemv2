l = golem.config.locale
module = golem.module.member
module.component.duplicate = golem.component.remove
  module: module
  class: golem.Member,
  key: 'memberId'
  nameFn: (item) -> item.fullname()
  confirm: 'MEMBERS_DUPLICATE_CONFIRM_MSG'
  route: '/member/list'
  acceptFn: ->
    delete @item._id
    delete @item._rev
    @item.creationDate = Date.now()
    @item.number = null
    @item.tags = []
    @item.activities = []
    @item.season = 2015
    golem.model.db.post @item, (err, res) =>
      if err
        golem.widgets.common.notifications.error
          body: '<em>' + err + '</em><br>' + l.ERROR_UPDATE,
          m.route.bind null, "/member/list"
      else
        golem.config.season = 2015
        golem.widgets.common.notifications.success
          body: l.SUCCESS_UPDATE,
          m.route.bind @, "/member/show/#{res.id}"
