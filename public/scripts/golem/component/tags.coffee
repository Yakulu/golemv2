l = golem.config.locale
widgets = golem.widgets.common
golem.component.tags =
  controller: (config) ->
    # Defaults
    {@title, getTagsFn, getDocsKey} = config
    mi = config.menuItems
    # Defaults
    field = config.field or 'tags'
    removeMsg = config.removeMsg or l.TAGS_MANAGEMENT_REMOVE_MSG
    @helpMsg = config.helpMsg or l.TAGS_MANAGEMENT_HELP_MSG
    # Init
    golem.menus.secondary.items = [mi.list, mi.add, mi.tags]
    golem.menus.secondary.items.push mi.skills if config.skills
    document.title = golem.utils.title @title
    @tags = []
    m.startComputation()
    getTagsFn (err, res) =>
      unless err
        @tags = res.rows.map (tag) -> tag.key[1]
      m.endComputation()

    @_updateTag = (removal) =>
      m.startComputation()
      oldVal = @input.getAttribute 'data-value'
      if removal
        newVal = false
      else
        newVal = @input.value
        if newVal.length is 0
          @input.value = oldVal
      golem.model.db.query 'tags/count',
        reduce: false
        key: [getDocsKey, oldVal]
        include_docs: true,
        (err, res) =>
          if err
            golem.widgets.common.notifications.errorUnexpected body: err
            m.endComputation()
          else
            docs = []
            res.rows.forEach (row) ->
              idx = row.doc[field].indexOf oldVal
              if newVal
                row.doc[field][idx] = newVal
              else
                row.doc[field].splice idx, 1
              docs.push row.doc

            golem.model.db.bulkDocs docs, (err, res) =>
              if err
                golem.widgets.common.notifications.errorUnexpected body: err
              else
                golem.widgets.common.notifications.success body: l.SUCCESS_UPDATE,
                =>
                  unless newVal
                    tagsIdx = @tags.indexOf oldVal
                    @tags.splice tagsIdx, 1
                    @removeModalCtrl.toggle()
                  else
                    @tags[@tags.indexOf oldVal] = newVal
              m.endComputation()

    @updateTagFromClick = (e) =>
      @input = e.target.parentElement.parentElement.children[0].children[0]
      @_updateTag()

    @removeModalCtrl = new widgets.modal.controller
      title: l.SURE
      content: removeMsg,
      acceptFn: => @_updateTag true

    @removeTag = (e) =>
      @input = e.target.parentElement.parentElement.children[0].children[0]
      @removeModalCtrl.toggle()
    return
  view: (ctrl) ->
    l = golem.config.locale
    mainContent = m 'section', [
      m 'h2', ctrl.title
      m 'ul', { class: 'ui bulleted list' }, ctrl.tags.map (tag) ->
        m 'li', { class: 'item golem-tag' }, [
          m 'span', { class: 'ui small input' }, [
            m 'input',
              size: 10
              value: tag
              'data-value': tag
          ]
          m 'span', { class: 'ui buttons' }, [
            m 'button',
              type: 'button'
              class: 'ui tiny blue button'
              onclick: ctrl.updateTagFromClick,
              l.RENAME
            m 'span.or'
            m 'button',
              type: 'button'
              class: 'ui tiny red button'
              onclick: ctrl.removeTag,
              l.DELETE
          ]
        ]
    ]
    contextMenuContent = m 'div', { class: 'six wide column' }, [
      m 'div', { class: 'ui purple inverted segment' }, [
        m 'h3', [
          m 'i', { class: 'info icon' }
          m 'span', l.HELP
        ]
        m 'p', m.trust ctrl.helpMsg
      ]
      new widgets.modal.view ctrl.removeModalCtrl
    ]
    return [
      m 'section', { class: 'ten wide column' }, [
        new golem.menus.secondary.view()
        mainContent
      ]
      m 'section', { class: 'six wide column' }, contextMenuContent
    ]
