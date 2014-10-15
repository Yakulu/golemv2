# Form Components

    notif = golem.common.notification

This common offers common components and helpers for forms.

    cform = {}

## Initialization

The init function takes optional `ns` and `callback` arguments to create a
namespaced finish function if there is a callback to call. It uses `props` to
pass to the views.

    cform.init = (ns, props, callback) ->
      finish = (callback, props) ->
        props = cform.render ns, props
        callback props.$dom
      ns.form.finish = _.partial finish, callback if callback

## Helpers

## Launch

The launch functions puts in place the secondary menu and initializes the
model for the form, a blank one in the case of a new member, or a filled one
when editing. It takes :

- a `ns` namespace for the module
- an optional `callback` function to be launched at the end of initialization
- an optional `id`, in case of edit

    cform.launch = (ns, callback, id) ->
      mi = ns.model.data.menuItems
      golem.menus.secondaryItems.replace [mi.list, mi.add]
      if id
        props = ns.form.initEdit callback, id
      else
        props = ns.form.initNew callback

### Render

`render` launched the rendering when all data has been gathered. This function
serves to define `finish` function if there is a callback.

    cform.render = (ns, props) -> ns.form.components.form props

## Views

`cancelButton` and `sendInput` are the two buttons for sending and cancelling
the form. They will be used at the bottom of the form and on the contextual
menu too. Both takes a `cls` argument for extending the default class.
`cancelButton` have an extra `clickFn` function that will be called when the
button is clicked.

    cform.views = {}

    cform.views.cancelButton = (cls, clickFn) ->
      button
        name: 'cancel'
        class: "ui button #{cls}"
        type: 'button'
        click: clickFn
        L 'CANCEL'

    cform.views.sendInput = (add, cls) ->
      input
        id: 'activity-submit'
        class: "ui teal submit button #{cls}"
        type: 'submit'
        form: 'activity-form'
        value: (if add then L 'SAVE' else L 'UPDATE')

### Tags

`tags`is a view that takes as argument the tags list, an array. It creates DOM
select element. It returns the element.

    cform.views.tags = (tags) ->
      select
        name: 'tags'
        class: 'tagfield'
        multiple: true, tags.map (t) ->
          option
            value: t
            label: t
            t

    cform.views.tagsChosenify = (selector) ->
      select = $ selector
      select.chosen
        no_results_text: L 'CHOSEN_NO_RESULTS_TAGS'
        placeholder_text_multiple: L 'CHOSEN_PLACEHOLDER_TEXT_TAGS'
      select.on 'chosen:no_results', (e, params) -> console.log e; console.log params


## Helpers

### Date formatting

Using moment.js and a little workaroung for DDMMYY random problems, given a
string value, `dateFormat` returns a moment Date Object or `null` if invalid.

    cform.dateFormat = (v) ->
      unless v
        null
      else
        v = v.replace(/\//g, '')
        if v and /^\d+$/.test v
          switch v.length
            when 1
              v = moment "0#{v}", 'DD'
            when 2
              v = moment v, 'DD'
            when 4
              v = moment v, 'DDMM'
            when 6
              # FIX for DDMMYY problems
              year = moment().format 'YY'
              ddmm = v.substr 0, 4
              yy = v.substr 4
              v = (if (yy > year) then "#{ddmm}19#{yy}" else "#{ddmm}20#{yy}")
              v = moment v, 'DDMMYYYY'
            when 8
              v = moment v, 'DDMMYYYY'
        else
          return null
        if v.isValid() then v else null

### Submission

`submit` function handles the form submission via the submission event and the
model, unlifted before submissions. It displays success and error notifications
and finally routes the user.

    cform.submit = (e, item) ->
      e.preventDefault()
      schema = item.schema.get()
      _submit = (verb) ->
        item = rx.unlift item
        golem.db[verb] item, (err, res) =>
          if err
            notif.send(
              notif.error
                content: '<em>' + err + '</em><br>' + L 'ERROR_UPDATE',
                displayCb: -> window.location.hash = "/#{schema}/list")
          else
            notif.send(
              notif.success
                content: L('SUCCESS_UPDATE'),
                displayCb: -> window.location.hash = "/#{schema}/show/#{res.id}")
      verb = (if item._id then 'put' else 'post')
      _submit verb

### Validation

`validate` is a function intended to build everything needed, around a form
field, to display validation errors when needed and hide them when the field is
conform. It relies on HTML5 and browser API. It takes :

- a validation `message` when error;
- a validation `validCallback` called after the event on which is bound the
validation occurs, only if the data is valid.

It returns an object containing the validation `$elt` to add to the form and
the `fn` function to launch for validation.

    cform.validate = (message, validCallback) ->
      $elt = div
        class: 'ui red pointing above label'
        style: display: 'none'
      , message
      fn = (e) ->
        name = e.target.getAttribute 'name'
        isValid = e.target.checkValidity()
        parent = $elt.parent()
        if isValid
          parent.removeClass 'error'
          $elt.css 'display', 'none'
          validCallback e if validCallback
        else
          parent.addClass 'error'
          $elt.css 'display', 'block'
      {$elt: $elt, fn: fn}

**TODO** :
- Simplify multifield only to an adding of existing $elements, passed by
  arguments, maybe with add/help buttons...

## Public API

    golem.common.form = cform
