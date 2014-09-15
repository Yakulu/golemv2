# Abstraction
l = golem.config.locale
golem.component.form =
  telsWidget: (module, item) ->
    new golem.widgets.form.multiFieldWidget.controller
      label: l.TELS
      name: 'tels'
      maxlength: 10
      size: 15
      radioField: true
      labelField: true
      labels: golem.model.labels.tels
      placeholder: l.TEL_PLACEHOLDER
      content: l.INFO_FORM_TELS
      current: item.tels

  mailsWidget: (module, item) ->
    new golem.widgets.form.multiFieldWidget.controller
      type: 'email'
      label: l.MAILS
      name: 'mails'
      size: 25
      radioField: true
      labelField: true
      labels: golem.model.labels.mails
      placeholder: l.MAIL_PLACEHOLDER
      content: l.INFO_FORM_MAILS
      current: item.mails

  wwwWidget: (item) ->
    new golem.widgets.form.multiFieldWidget.controller
      type: 'url'
      label: l.WWW
      name: 'www'
      placeholder: l.WWW_PLACEHOLDER
      content: l.INFO_FORM_WWW
      current: item.www

  tagWidget: (module, current) ->
    new golem.widgets.form.tagWidget.controller
      name: 'tags'
      label: l.TAGS
      placeholder: l.TAGS_PLACEHOLDER
      content: l.INFO_FORM_TAGS
      size: 25
      tags: tag.key[1] for tag in module.data.tags
      current: current

  submit: (itemField, e) ->
    item = @[itemField]
    e.preventDefault()
    _submit = (verb) ->
      golem.model.db[verb] item, (err, res) =>
        if err
          golem.widgets.common.notifications.error
            body: '<em>' + err + '</em><br>' + l.ERROR_UPDATE,
            m.route.bind null, "/#{itemField}/list"
        else
          golem.widgets.common.notifications.success
            body: l.SUCCESS_UPDATE,
            m.route.bind @, "/#{itemField}/show/#{res.id}"
    verb = (if item._id then 'put' else 'post')
    _submit verb
