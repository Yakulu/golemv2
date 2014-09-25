# GOLEM Activity class

An `Activity` takes a `props` object as argument, with :

- `label`, string required;
- `code` string, an optional shortcut for the activity;
- `places` integer, the number of places available;
- `timeSlot` string;
- `monitor` string;
- `note` for extra remarks;

`activity` is the model for activities. In case of a new activity, the function
creates a new object with defaults, otherwise it checks if the identifier is
provided. If yes, it returns the object, else it just overwrites eventual
missing defaults. Lifting is then done to enable precise reactivity.

    activity = (props) ->
      defaults =
        schema: 'activity'
        creationDate: Date.now()
        label: ''
        code: ''
        timeSlot: ''
        monitor: ''
        places: null
        note: ''
      unless props
        me = _.clone defaults
      else
        me = if props._id then props else _.defaults props, defaults
      rx.lift me

`fullLabel` is a method helping to get a whole sentence representing an
`activity`, passed as argument. It creates a dependent cell.

    fullLabel = (activity) ->
      bind ->
        if activity.code.get()
          "#{activity.code.get()} #{activity.label.get()}"
        else
          activity.label.get()

## menuItems

Here are the items for the secondary menu. Module will pick into them for
displaying.

    menuitem = golem.menus.menuitem
    menuItems =
      list: menuitem L('LIST'), '/activity', 'list'
      add: menuitem L('NEW'), '/activity/add', 'add sign'
      show: menuitem L('VIEW'), '/activity/show', 'search'
      edit: menuitem L('EDIT'), '/activity/edit', 'edit'
      remove: menuitem L('DELETE'), '/activity/remove', 'remove'

## Public API

Global shares

    golem.activity.model =
      activity: activity
      fullLabel: fullLabel
      data:
        items: []
        menuItems: menuItems
