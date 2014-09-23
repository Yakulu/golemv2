# Remove component

This module provides common actions around a `$modal` component to remove a
record from database.
It takes a `config` object as argument :

* `approveCb` is the callback that will be called after approval. If not given,
the module provides a default one, with removing from the database and
displaying standard notifications
* `route` is the hash where the user will be redirect after approval or deny
* `id` is the document identifier for removal
* `Class` is the component Class (CoffeeScript sense), usefull for instantiate
it before removal
* `nameField` is the field to be used to update the document's title according
to the name of the removed document
* `content` is the key of the locale containing the HTML content for the modal

    notif = golem.component.notification

    remove = (config) ->
      unless config.approveCb
        config.approveCb = (item) ->
          golem.db.remove item, (err, res) ->
            if err
              new notif.Unexpected(content: err).send()
            else
              new notif.Success(content: L 'SUCCESS_DELETE').send()
            window.location.hash = config.route
      golem.db.get config.id, (err, res) ->
        if err
          new notif.Error(content: L 'ERROR_RECORD_NOT_FOUND').send()
          window.location.hash = config.route
        else
          item = new config.Class res
          document.title = golem.utils.title(
            L('REMOVAL_OF') + item[config.nameField].get())
          golem.component.common.$modal
            title: L 'SURE'
            content: "<p>#{L(config.content)}</p>"
            approveCb: config.approveCb.bind(null, item)
            denyCb: -> window.location.hash = config.route

## Public API

    golem.component.remove = remove
