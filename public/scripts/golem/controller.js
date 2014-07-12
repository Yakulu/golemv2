(function () {
  golem.controller = function () {
    this.docTitle = golem.utils.locale('TITLE') + ' - ';
    document.title =  this.docTitle + golem.utils.locale('MENU_HOME');

    this.mainMenu = new golem.menus.main.controller();
    this.secondaryMenu = new golem.menus.secondary.controller();
  };
}).call(this);
