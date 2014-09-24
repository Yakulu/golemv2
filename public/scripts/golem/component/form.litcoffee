# Form Components

This component offers common components and helpers for forms.

    class golem.component.Form

## Static properties

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
