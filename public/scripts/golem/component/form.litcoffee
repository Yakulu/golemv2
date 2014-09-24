# Form Components

This component offers common components and helpers for forms.

    class golem.component.Form

## Views

`cancelButton` and `sendInput` are the two buttons for sending and cancelling
the form. They will be used at the bottom of the form and on the contextual
menu too. Both takes a `cls` argument for extending the default class.
`cancelButton` have an extra `clickFn` function that will be called when the
button is clicked.

      cancelButton: (cls, clickFn) ->
        button
          name: 'cancel'
          class: "ui button #{cls}"
          type: 'button'
          click: clickFn
          L 'CANCEL'

      sendInput: (cls) ->
        input
          id: 'activity-submit'
          class: "ui teal submit button #{cls}"
          type: 'submit'
          form: 'activity-form'
          value: (if @add then L 'SAVE' else L 'UPDATE')

## Static properties

### Date formatting

Using moment.js and a little workaroung for DDMMYY random problems, given a
string value, `dateFormat` returns a moment Date Object or `null` if invalid.

      @dateFormat: (v) ->
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

`@submit` static property handles the form submission via the submission event
and the model, unlifted before submissions. It displays success and error
notifications and finally routes the user.

      @submit: (e, item) ->
        e.preventDefault()
        schema = item.schema.get()
        _submit = (verb) ->
          item = rx.unlift item
          golem.db[verb] item, (err, res) =>
            if err
              new golem.component.notification.Error
                content: '<em>' + err + '</em><br>' + L 'ERROR_UPDATE',
                window.location.hash = "/#{schema}/list"
              .send()
            else
              new golem.component.notification.Success
                content: L 'SUCCESS_UPDATE',
                window.location.hash = "/#{schema}/show/#{res.id}"
              .send()
        verb = (if item._id then 'put' else 'post')
        _submit verb

### Validation

`@validate` is a static property intended to build everything needed, around a
form field, to display validation errors when needed and hide them when the
field is conform. It relies on HTML5 and browser API. It takes :

- a validation `message` when error;
- a validation `validCallback` called after the event on which is bound the
  validation occurs, only if the data is valid.

It returns an object containing the validation `$elt` to add to the form and
the `fn` function to launch for validation.

      @validate : (message, validCallback) ->
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
- To Class
- Simplify multifield only to an adding of existing $elements, passed by
  arguments, maybe with add/help buttons...

## Public API

    golem.component.form = form
