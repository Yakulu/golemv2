# GOLEM Activity class

An `Activity` takes a `props` object as argument, with :

* `label`, string required;
* `code` string, an optional shortcut for the activity;
* `places` integer, the number of places available;
* `timeSlot` string;
* `monitor` string;
* `note` for extra remarks;

`Activity` inherits from `Doc`. In case of a new activity, the class creates a
new instance with defaults. Lifting is done to enable precise reactivity.

    class golem.Activity extends golem.Doc
      constructor: (props) ->
        super props
        unless @_id
          props ?= {}
          @schema = 'activity'
          @creationDate = Date.now()
          @label = props.label or ''
          @code = props.code or ''
          @timeSlot = props.timeSlot or ''
          @monitor = props.monitor or ''
          @places = props.places or null
          @note = props.note or ''
          rx.lift @

`fullLabel` is a method helping to get a whole sentence representing the
`Activity`.

      fullLabel: -> if @code then "#{@code} #{@label}" else @label

## menuItems

Here are the items for the secondary menu. Module will pick into them for
displaying.

    Menu = golem.menus.Menu
    menuItems =
      list: new Menu L('LIST'), '/activity/list', 'list'
      add: new Menu L('NEW'), '/activity/add', 'add sign'
      show: new Menu L('VIEW'), '/activity/show', 'search'
      edit: new Menu L('EDIT'), '/activity/edit', 'edit'
      remove: new Menu L('DELETE'), '/activity/remove', 'remove'

## Public API

Global shares

    golem.activity.model =
      data:
        items: []
        menuItems: menuItems
