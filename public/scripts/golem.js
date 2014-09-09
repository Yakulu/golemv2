(function () {
  'use strict';

  /*var menus
  window.onhashchange = function () {
  menus.foreach(function (m) {
  m.render();
});
  };*/

  // Database
  var db = golem.model.db;
  // TMP DEV : Repopulate at launch...
  //db.destroy(function () {
    //  golem.model.db = new PouchDB('golem');
    //  db = golem.model.db;
    db.allDocs(function (err, response) {
      if (err || response.rows.length === 0) {
        db.bulkDocs(golem.module.contact.data.items, function (err, response) {
          var gmq = golem.model.queries;
          var queries = [gmq.all, gmq.tags, gmq.labels];
          db.bulkDocs(queries, function (err, response) {
            init();
          });
        });
      } else {
        init();
      }
    });
  //});
  var init = function () {
    // Layout modules initialization
    var roots = {
      header: document.getElementById('golem-header'),
      mainMenu: document.getElementById('golem-mainmenu'),
      //contextMenu: document.getElementById('golem-contextmenu'),
      main: document.getElementById('golem-main'),
      footer: document.getElementById('golem-footer'),
    };
    m.module(roots.header, golem.header);
    m.module(roots.footer, golem.footer);
    m.module(roots.mainMenu, golem.menus.main);
    //m.module(roots.contextMenu, golem.home.context);

    var gm = golem.module;
    // Routing
    m.route.mode = 'hash';
    m.route(roots.main, '/', {
      '/': golem.home.main,
      '/family': gm.family.component.list,
      '/family/list': gm.family.component.list,
      '/family/add': gm.family.component.form,
      '/family/edit/:familyId': gm.family.component.form,
      '/family/show/:familyId': gm.family.component.show,
      '/family/remove/:familyId': gm.family.component.remove,
      '/contact': gm.contact.component.list,
      '/contact/list': gm.contact.component.list,
      '/contact/list/page/:page': gm.contact.component.list,
      '/contact/tags': gm.contact.component.tags,
      '/contact/show/:contactId': gm.contact.component.show,
      '/contact/add': gm.contact.component.form,
      '/contact/edit/:contactId': gm.contact.component.form,
      '/contact/remove/:contactId': gm.contact.component.remove,
      '/member': gm.member.component.list,
      '/member/list': gm.member.component.list,
      '/member/tags': gm.member.component.tags,
      '/member/skills': gm.member.component.skills,
      '/member/add': gm.member.component.form,
      '/member/edit/:memberId': gm.member.component.form,
      '/member/show/:memberId': gm.member.component.show,
      '/member/remove/:memberId': gm.member.component.remove,
    });
  };
}).call(this);
