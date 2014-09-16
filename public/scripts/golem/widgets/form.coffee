# Form commons
widgets = golem.widgets.common
form = golem.widgets.form =
  addButton: (clickAction, text) ->
    m 'button',
      class: 'ui right attached tiny button'
      type: 'button'
      onclick: clickAction,
      [
        m 'i',
          class: 'add sign icon'
        text
      ]

  helpButton:
    controller: (@title, @content, @extra) ->
      @isPopupVisible = false
      @togglePopup = => @isPopupVisible = not @isPopupVisible
      return

    view: (ctrl) ->
      l = golem.config.locale
      box = []
      cls = 'ui tiny button'
      if ctrl.extra
        cls = "#{cls} left attached"
        box.push ctrl.extra
      box.unshift m 'button',
        class: (if ctrl.isPopupVisible then cls + ' black' else cls)
        type: 'button'
        'data-title': ctrl.title
        'data-content': ctrl.content
        onclick: ctrl.togglePopup, [
          m 'i', { class: 'help icon' }
          l.HELP
        ]
      popup = m 'div', { class: 'ui visible center right inverted popup helper' }, [
        m 'div.header', [
          m 'i',
            role: 'button'
            class: 'close icon'
            onclick: ctrl.togglePopup
          ctrl.title
        ]
        m 'p.content', m.trust ctrl.content
      ]
      box.unshift popup  if ctrl.isPopupVisible
      m 'div', box

  selectHelper: (config) ->
    selectAttr = {}
    m 'select', selectAttr

  inputHelper: (config) ->
    # Defaults
    placeholder = config.placeholder or config.label
    type = config.type or 'text'
    name = config.name + (config.suffix or '')
    # Attributes
    inputAttr =
      id: name
      name: name
      type: type
      placeholder: placeholder
      value: config.value
    inputAttr.class = config.inputCls if config.inputCls
    inputAttr.maxlength = config.maxlength if config.maxlength
    inputAttr.minlength = config.minlength if config.minlength
    inputAttr.size = config.size if config.size
    inputAttr.required = 'required' if config.required
    inputAttr.pattern = config.pattern if config.pattern
    inputAttr.onchange = config.onchange if config.onchange
    inputAttr.oninput = config.oninput if config.oninput
    if config.validationMsg
      validateFn = (e) ->
        name = e.target.getAttribute 'name'
        isValid = e.target.checkValidity()
        parent = e.target.parentNode
        if isValid
          parent.classList.remove 'error'
          parent.lastChild.style.display = 'none'
        else
          parent.classList.add 'error'
          parent.lastChild.style.display = 'block'
        config.validationCallback e  if config.validationCallback
        return
      inputAttr.oninput = validateFn
      inputAttr.onblur = validateFn
    # Element
    m 'input', inputAttr

  textHelper: (config) ->
    cls = config.cls or 'field small input'
    if config.required
      labelText = "* #{config.label}"
    else
      labelText = config.label
    label = m 'label', { for: config.name }, labelText
    if config.validationMsg
      validationElement = m 'div',
        class: 'ui red pointing above label'
        style: { display: 'none' },
        config.validationMsg
    else
      validationElement = ''
    m 'div', { class: cls }, [
      label
      form.inputHelper config
      validationElement
    ]

  multiFieldWidget:
    # TODO : non trivial, make fidel representation of fields in reactive elements for m.withAttr...
    controller: (config) ->
      l = golem.config.locale
      # Internal state
      {@tagName, @type, @label, @name, @size, @maxlength, @minlength, @content, @current} = config
      # Defaults
      @required = config.required or 'required'
      @placeholder = config.placeholder or ''
      @radioField = config.radioField or false
      @labelField = config.labelField or false
      @labels = config.labels or []
      @removeNum = m.prop()
      @suffix = m.prop()
      @value = ''
      # Methods

      @setSuffix = (num) => @suffix = "-#{num}"

      @setValue = (obj) =>
        @value = if obj.value? then obj.value else obj

      @addField = =>
        unless @labelField
          field = ''
        else
          field = { label: '', value: '' }
          field.default = false if @radioField
        @current.push field

      @change = (num, field, e) =>
        switch field
          when 'default'
            (c.default = (idx is num)) for c, idx in @current
          when 'www'
            @current[num] = e.target.value
          else # Label and classic value
            @current[num][field] = e.target.value

      # Children Modules
      @helpButton = new form.helpButton.controller(@label, @content,
        form.addButton @addField, l.NEW)

      # Remove Modal
      removeField = =>
        @current.splice @removeNum(), 1
        @removeModalCtrl.toggle()

      @removeModalCtrl = new widgets.modal.controller
        title: l.SURE
        content: l.REMOVE_FIELD_CONFIRM_MSG
        acceptFn: removeField
      return

    view: (ctrl) ->
      l = golem.config.locale
      # Buttons
      # Input and remove fields
      inputRemoveFields = (num) ->
        ctrl.setSuffix num
        fields = []
        sel = ctrl.current[num]
        # Radio field
        if ctrl.radioField
          checked = if sel then sel.default else false
          radioField = m 'input',
            class: 'ui radio checkbox'
            title: l.DEFAULT
            type: 'radio'
            name: "#{ctrl.name}-default"
            required: 'required'
            value: num
            checked: checked
            onchange: ctrl.change.bind ctrl, num, 'default'
          fields.push m 'div', { class: 'two wide inline field' }, [
            radioField
            m 'label.small', { for: ctrl.name }, l.DEFAULT
          ]
        # Label field
        if ctrl.labelField
          fieldId = "#{ctrl.name}-label-#{num}"
          labelField = m 'div', { class: 'seven wide field' }, [
            m 'input',
              type: 'text'
              list: fieldId
              name: fieldId
              placeholder: l.TYPE
              size: 15
              value: (if sel then sel.label else '')
              onchange: ctrl.change.bind ctrl, num, 'label'
            m 'datalist', { id: fieldId }, ctrl.labels.map (label) ->
              m 'option', { value: label.key[1] }
          ]
          fields.push labelField
        # Remove button
        removeField = m 'div',
          role: 'button'
          class: 'ui tiny red icon button'
          title: l.DELETE
          onclick: ->
            ctrl.removeNum num
            ctrl.removeModalCtrl.toggle()
          , [
            m 'i', { class: 'remove sign icon' }
          ]
        # All fields
        ctrl.setValue sel

        unless ctrl.labelField
          ctrl.onchange = ctrl.change.bind ctrl, num, 'www'
        else # Complex fields like mail and tel
          ctrl.onchange = ctrl.change.bind ctrl, num, 'value'
        valueField = if (ctrl.tagName? is 'select') then form.selectHelper ctrl else form.inputHelper ctrl
        fields.push m 'div', { class: 'seven wide field' }, [
          m 'div', { class: 'ui action input' }, [ valueField, removeField ]
        ]
        m 'div', { class: 'multitext fields' }, fields

      fieldset = m 'fieldset', { class: 'ui segment' }, [
        m 'legend', ctrl.label
        new form.helpButton.view ctrl.helpButton
        m 'div', inputRemoveFields i for item, i in ctrl.current
        new widgets.modal.view ctrl.removeModalCtrl
      ]
      m 'div.field', [fieldset]

  tagWidget:
    controller: (config) ->
      # Initialization
      {@label, @placeholder, @content, @tags, @current} = config
      # Defaults
      @size = config.size or 10
      @name = config.name or 'tags'
      # All tags except those already selected
      tags = (tag for tag in @tags when tag not in @current)
      # Children modules
      @helpButton = new form.helpButton.controller @label, @content
      # Methods
      @add = (input) =>
        v = input.value
        @current.push v if v and v not in @current
        vIdx = @tags.indexOf v
        @tags.splice(vIdx, 1) if vIdx isnt -1
        input.value = ''
      return

    view: (ctrl) ->
      l = golem.config.locale
      m 'div', { class: 'field tagfield' }, [
        m 'fieldset', { class: 'ui segment' }, [
          m 'legend', ctrl.label
          new form.helpButton.view ctrl.helpButton
          m 'div', { class: 'ui action input multitext' }, [
            m 'input',
              id: "#{ctrl.name}-input"
              name: ctrl.name
              type: 'text'
              list: ctrl.name
              placeholder: ctrl.placeholder
              size: ctrl.size
              onkeydown: (e) ->
                if e.keyCode is 13 # ENTER
                  e.preventDefault()
                  ctrl.add e.target

              onchange: (e) ->
                ctrl.add e.target
          m 'div',
            role: 'button'
            class: 'ui mini purple button'
            onclick: (e) ->
              ipt = document.getElementById "#{ctrl.name}-input"
              ctrl.add ipt
            , l.OK
        ]
        m 'datalist', { id: ctrl.name }, ctrl.tags.map (tag) ->
          m 'option', { value: tag }
        m 'p', ctrl.current.map (tag) ->
          m 'div', { class: 'ui label purple golem-tag' }, [
            tag
            m 'i',
              role: 'button'
              class: 'delete icon'
              onclick: (e) ->
                value = e.target.parentElement.textContent
                idx = ctrl.current.indexOf value
                ctrl.current.splice idx, 1
                ctrl.tags.push value
          ]
        ]
      ]
