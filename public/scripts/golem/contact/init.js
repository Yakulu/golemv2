(function () {
  // Contacts
  var contact = golem.module.contact = {};
  contact.component = {};
  $script('contact/data', function () {
    $script([
      'contact/component/list',
      'contact/component/show',
      'contact/component/form',
      'contact/component/remove',
      'contact/component/tags'
    ], 'contactComponents');
    $script.ready('contactComponents', function () {
      $script.done('contact/init');
    });
  });
}).call(this);
