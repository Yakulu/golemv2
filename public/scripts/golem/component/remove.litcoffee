# Remove component

This module provides common actions around a `modal` component to remove a
record from database.

    notif = golem.component.notification

`approveCb` is the private callback provided by default if none has been given.
It will remove from the database and display standard notifications

    _approveCb = (route, item) ->
      golem.db.remove item, (err, res) ->
        if err
          notif.send(notif.unexpected content: err)
        else
          notif.send(notif.success content: L 'SUCCESS_DELETE')
          window.location.hash = route

`remove` takes a `config` object as argument :

- `approveCb`, an optional function, the callback that will be called after
  approval;
- `route` is the hash where the user will be redirect after approval or deny;
- `id` is the document identifier for removal;
- `model` is the component model creation function, usefull for getting the
  model before removal;
- `nameField` is the field to be used to update the document's title according
  to the name of the removed document;
- `content` is the key of the locale containing the HTML content for the modal

    remove = (config) ->
      config.approveCb ?= _.partial _approveCb, config.route
      golem.db.get config.id, (err, res) ->
        if err
          notif.send(notif.error content: L('ERROR_RECORD_NOT_FOUND'))
          window.location.hash = config.route
        else
          item = config.model res
          document.title = golem.utils.title(
            L('REMOVAL_OF') + item[config.nameField].get())
          golem.component.common.modal
            title: L 'SURE'
            content: "<p>#{L(config.content)}</p>"
            approveCb: _.partial config.approveCb, item
            denyCb: -> window.location.hash = config.route

## Public API

    golem.component.remove = remove
