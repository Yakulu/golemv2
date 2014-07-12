$script.ready('startpack', function () {
  'use strict';

  $script.path('/scripts/golem/');
  $script([ 'utils', 'menus', 'widgets/common', 'widgets/form' ], 'common');
  $script([ 'model', 'controller', 'view' ], 'mvc');

  $script.ready(['common', 'mvc'], function () {
    $script([ 'contact/init'], 'modules');
    $script.ready('modules', function () {

  /*var menus
  window.onhashchange = function () {
    menus.foreach(function (m) {
      m.render();
    });
  };*/

  window.onload = function () {
    // Database
    var db = golem.model.db;
    // TMP DEV : Repopulate at launch...
    //db.destroy(function () {
    //  golem.model.db = new PouchDB('golem');
    //  db = golem.model.db;
      db.allDocs(function (err, response) {
        if (err || response.rows.length === 0) {
          db.bulkDocs(contact.data.items, function (err, response) {
            var gmq = golem.model.queries;
            var queries = [gmq.all, gmq.tags];
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
      var gm = golem.module;
      // Routing
      m.route.mode = 'hash';
      m.route(document.body, '/', {
        '/': golem,
        '/contact': gm.contact.component.list,
        '/contact/list': gm.contact.component.list,
        '/contact/list/filter/tag/:tag': gm.contact.component.list,
        '/contact/list/page/:page': gm.contact.component.list,
        '/contact/tags': gm.contact.component.tags,
        '/contact/show/:contactId': gm.contact.component.show,
        '/contact/add': gm.contact.component.form,
        '/contact/edit/:contactId': gm.contact.component.form,
        '/contact/remove/:contactId': gm.contact.component.remove
      });
    };
  };
  });
  });
});
