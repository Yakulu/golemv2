# Form Components

This class offers common components and helpers for forms.

    class Form

`@submit` function handles the form submission via the submission event and the
model, displays success and error notifications and finally routes the user.

      @submit: (e, item) ->
        schema = item.schema.get()
        e.preventDefault()
        _submit = (verb) ->
          golem.db[verb] item, (err, res) =>
            if err
              golem.component.common.notifications.error
                body: '<em>' + err + '</em><br>' + l.ERROR_UPDATE,
                window.location.hash = "/#{schema}/list"
            else
              golem.component.common.notifications.success
                body: l.SUCCESS_UPDATE,
                window.location.hash = "/#{schema}/show/#{res._id}"
        verb = (if item._id.get() then 'put' else 'post')
        _submit verb

`@validate` is a function intended to build everything needed, around a form
field, to display validation errors when needed and hide them when the field is
conform. It relies on HTML5 and browser API. It takes :

* a validation `message` when error;
* a validation `validCallback` called after the event on which is bound the
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

## Public API

    golem.component.Form = Form
