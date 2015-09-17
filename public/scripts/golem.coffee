'use strict'

###
menus
window.onhashchange = ->
menus.foreach(function (m) {
m.render()
})
};
###

# Database
db = golem.model.db
# TMP DEV : Repopulate at launch...
#db.destroy(->
  #  golem.model.db = new PouchDB('golem')
  #  db = golem.model.db
db.allDocs (err, response) ->
  if  err or response.rows.length is 0
    db.bulkDocs golem.module.contact.data.items, (err, response) ->
      gmq = golem.model.queries
      queries = [gmq.all, gmq.tags, gmq.labels, gmq.members]
      db.bulkDocs queries, (err, response) -> init()
  else
    init()

init = ->
  # Layout modules initialization
  golem.roots =
    header: document.getElementById 'golem-header'
    mainMenu: document.getElementById 'golem-mainmenu'
    #contextMenu: document.getElementById('golem-contextmenu')
    main: document.getElementById 'golem-main'
    footer: document.getElementById 'golem-footer'
    notifications: document.getElementById 'golem-notifications'

  roots = golem.roots
  m.module roots.header, golem.header
  m.module roots.footer, golem.footer
  m.module roots.mainMenu, golem.menus.main
  m.module roots.notifications, golem.widgets.common.notifications
  #m.module(roots.contextMenu, golem.home.context)
  # TMP : AUTH
  m.module roots.main, golem.auth.main

golem.initRouting = ->
  gm = golem.module
  roots = golem.roots
  # Routing
  m.route.mode = 'hash'
  m.route(roots.main, '/', {
    '/': golem.home.main
    '/auth': golem.auth.main
    ###
    '/family': gm.family.component.list
    '/family/list': gm.family.component.list
    '/family/add': gm.family.component.form
    '/family/edit/:familyId': gm.family.component.form
    '/family/show/:familyId': gm.family.component.show
    '/family/remove/:familyId': gm.family.component.remove
    '/contact': gm.contact.component.list
    '/contact/list': gm.contact.component.list
    '/contact/list/page/:page': gm.contact.component.list
    '/contact/tags': gm.contact.component.tags
    '/contact/show/:contactId': gm.contact.component.show
    '/contact/add': gm.contact.component.form
    '/contact/edit/:contactId': gm.contact.component.form
    '/contact/remove/:contactId': gm.contact.component.remove
    ###
    '/contact': gm.contact.component.list
    '/contact/list': gm.contact.component.list
    '/contact/tags': gm.contact.component.tags
    '/contact/show/:contactId': gm.contact.component.show
    '/contact/remove/:contactId': gm.contact.component.remove
    '/contact/add': gm.contact.component.form
    '/contact/edit/:contactId': gm.contact.component.form
    '/member': gm.member.component.list
    '/member/list': gm.member.component.list
    '/member/tags': gm.member.component.tags
    '/member/skills': gm.member.component.skills
    '/member/add': gm.member.component.form
    '/member/edit/:memberId': gm.member.component.form
    '/member/show/:memberId': gm.member.component.show
    '/member/remove/:memberId': gm.member.component.remove
    '/member/duplicate/:memberId': gm.member.component.duplicate
    '/activity': gm.activity.component.list
    '/activity/list': gm.activity.component.list
    '/activity/add': gm.activity.component.form
    '/activity/show/:activityId': gm.activity.component.show
    '/activity/edit/:activityId': gm.activity.component.form
    '/activity/remove/:activityId': gm.activity.component.remove
    '/activity/duplicate/:activityId': gm.activity.component.duplicate
  })
