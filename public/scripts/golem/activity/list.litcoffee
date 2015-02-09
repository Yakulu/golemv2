# Activity List

This component represents the listing of activities, a table served with global
and advanced search. It inherits from the common `list`.

    notif = golem.common.notification
    ns = golem.module.activity
    gclist = golem.common.list

    list = {}

## Module initialization and launch

Here is the component initialization. It calls the common list constructor. See
`golem.common.list` for that. And :

- creates `takenPlacesByActivity` will be a reactive map, populated by a db
  request, for the sum of all subscribed members by activity;
- replace `searches` with the known three fields that we'll use here.
- then calls `setup` and the asynchronous `getActivities`.

    list.launch = (callback) ->
      props = gclist.init ns, callback
      props.takenPlacesByActivity = rx.map()
      props.searches.update label: '', code: '', monitor: ''
      list.setup()
      list.getActivities props, list.getMembersFromActivity
      

With `setup`, we set the document's title and the secondary menu items.

    list.setup = ->
      document.title = golem.utils.title L 'ACTIVITIES_LIST'
      mi = ns.model.data.menuItems
      golem.menus.secondaryItems.replace [mi.list, mi.add]

## Activities

List needs to get `items`. It uses the db helper function `getBySchema` for it,
passing a callback that displays an `Unexpected` error if a problem occurs.
It calls the callback function, with the forwarded one, the rendering or
finishing.

    list.getActivities = (props, callback) ->
      golem.model.getBySchema 'activity', (err, res) ->
        if err
          notif.send(notif.unexpected content: err)
        else
          props._items = res.rows.map (r) -> ns.model.activity r.doc
          props.items.replace props._items
          # TODO: use count reduce for this purpose, instead of doing manually
        callback props, list.finish or list.render

`getMembersFromActivity` gets members subscribed for all activities, allowing
display of the taken and remaining places for each and then calls the callback.

    list.getMembersFromActivity = (props, callback) ->
      golem.model.getMembersFromActivity null, (err, res) =>
        if err
          notif.send(notif.unexpected content: err)
        else
          _takenPlacesByActivity = {}
          for r in res.rows
            aId = r.key[0]
            _takenPlacesByActivity[aId] ?= 0
            _takenPlacesByActivity[aId] += 1
          props.takenPlacesByActivity.update _takenPlacesByActivity
          callback props

## List methods

### Global search

`searchGlobal` is a function that employs the common `search` helper
to provide a full text, but slow, research in all activities. The search
function is called only if the search input is valid.

    list.searchGlobal = (props, e) ->
      el = e.target
      if el.checkValidity()
        props.filters.put 'search', _.partial(gclist.searchJSON, el.value)
      else
        props.filters.remove 'search' if props.filters.get 'search'
      props.items.replace gclist.filter(props.filters, props._items)
      props

### Advanced search

`searchAdvanced` takes a `reset` boolean as first argument. If reset is true,
the function makes all `searches` empty and removes the corresponding `filters`
if they exist. Otherwise, it removes the filter only if the value of the search
is empty and add the filters on `filters` if the value has been filled. The
second argument, `e` is the jQuery event for the form submission. It's only
here for preventing default behavior.

    list.searchAdvanced = (props, reset, e) ->
      e.preventDefault()
      _.chain(props.searches.all()).keys().each (field) ->
        unless reset
          if props.searches.get(field).length is 0
            props.filters.remove field if props.filters.get field
          else
            value = props.searches.get(field).toLowerCase()
            props.filters.put field, (item) ->
              item[field].get().toLowerCase().indexOf(value) isnt -1
        else
          props.searches.put field, ''
          props.filters.remove field if props.filters.get field
      props.items.replace gclist.filter(props.filters, props._items)
      props

## List Views

    list.views = {}

### Advanced Search DOM

`avdancedSearch` is a form witch contains all fields where a user can search
to filter the activities list. Each search can be cumulated, thanks to
`filters` instance method. Search is submitted via a send button and can be
globally canceled via a cancel button.

    list.views.advancedSearch = (props) ->
      props.$dom = form
        class: 'ui small form'
        submit: _.partial(props.searchAdvancedFn, props, false),
        [
          fieldset { class: 'fields' }, [
            legend [
              i { class: 'icon help' }
              span L 'SEARCH_ADVANCED_HELP'
            ]
            input
              class: 'five wide column field input'
              type: 'text'
              name: 'label'
              placeholder: L 'LABEL'
              maxlength: 100
              value: bind -> props.searches.get 'label'
              keyup: (e) -> props.searches.put 'label', e.target.value
            input
              class: 'two wide column field input'
              type: 'text'
              name: 'code'
              placeholder: L 'CODE'
              maxlength: 30
              value: bind -> props.searches.get 'code'
              keyup: (e) -> props.searches.put 'code', e.target.value
            input
              class: 'four wide column field input'
              type: 'text'
              name: 'monitor'
              placeholder: L 'MONITOR'
              maxlength: 50
              value: bind -> props.searches.get 'monitor'
              keyup: (e) -> props.searches.put 'monitor', e.target.value
            div { class: 'ui buttons' }, [
              input
                class: 'ui green small submit button'
                type: 'submit'
                value: L 'OK'
              button
                name: 'cancel'
                class: 'ui small button'
                type: 'button'
                click: _.partial(props.searchAdvancedFn, props, true),
                L 'CANCEL'
            ]
          ]
        ]
      props

### Place DOM

`placeView` is the property, a function which returns, for a given activity, the
span DOM elementwith an adapted color, according to the remaining places

    list.views.place = (props, activity) ->
      color = 'inherit'
      if activity.places.get()
        taken = props.takenPlacesByActivity.get(activity._id.get())
        remain = activity.places.get() - taken
        color = switch
          when remain <= 0 then 'red'
          when remain < 5 then 'orange'
          else 'green'
      span
        style: { color: color },
        props.takenPlacesByActivity.get(activity._id.get()) or 0

### Activity DOM

`activityView` is a method that returns the table row corresponding to the given
activity.

    list.views.activity = (props, activity) ->
      act = activity
      id = act._id.get()
      tr [
        td act.label.get()
        td act.code.get()
        td act.timeSlot.get()
        td act.monitor.get()
        td act.places.get()
        list.views.place props, activity
        td { class: 'actions' }, [
          a
            href: "#/activity/show/#{id}"
            title: L('VIEW'),
            [i { class: 'unhide icon' }]
          a
            href: "#/activity/edit/#{id}"
            title: L('EDIT'),
            [i { class: 'edit icon' }]
          a
            href: "#/activity/remove/#{id}"
            title: L('DELETE'),
            [i { class: 'remove icon' }]
        ]
      ]

### Table header

`thead` table header, with sortable columns.

    list.views.thead = (props) ->
      sthProps =
        sortFn: props.sortFn
        items: props.items
      sth = gclist.components.sortableTableHeader
      props.$dom = thead [
          tr [
            sth(_.defaults sthProps, field: 'label').$dom
            sth(_.defaults sthProps, field: 'code').$dom
            th L('TIMESLOT')
            sth(_.defaults sthProps, field: 'monitor').$dom
            sth(_.defaults sthProps, field: 'places').$dom
            th L('PLACES_TAKEN')
            th { width: '10%' }, L 'ACTIONS'
          ]
        ]
      props

### Right Sidebar

The right sidebar is only composed by the global search component.

    list.views.sidebar = (props) ->
      sprops =
        searchFn: _.partial props.searchGlobalFn, props
        inputAttr: { pattern: '.{4,}' }
      searchComponent = gclist.components.search sprops
      props.$dom = nav [
        menu { class: 'ui small vertical menu' }, searchComponent.$dom
      ]
      props

### Global DOM

Finally, a function returning the DOM list corresponding to the component, with
the header and the table.

    list.views.layout = (props) ->
      searchAdv = props.searchAdvancedOn
      props.$dom = [
        section { class: 'twelve wide column' }, [
          golem.menus.secondary
          golem.common.widgets.headerExpandable
            class: 'inverted center aligned black'
            title: L 'SEARCH_ADVANCED'
            active: searchAdv
          p bind ->
            if searchAdv.get()
              list.views.advancedSearch(props).$dom
            else
              ''
          h3 { class: 'ui inverted center aligned purple header' },
            span L 'ACTIVITIES_LIST'
          props.$dom
        ]
        section { class: 'four wide column' },
          list.views.sidebar(props).$dom
      ]
      props

## Components

    list.components = {}

`list` is the unique component of this page, composing all views and passing to
them the `props` objects, updated to add mandatory functions in our situation.

    list.components.list = (props) ->
      props.searchAdvancedFn = list.searchAdvanced
      props.searchGlobalFn = list.searchGlobal
      props.sortFn = gclist.sort
      props.rowFn = list.views.activity
      v = list.views
      tableContent = (props) ->
        props.$dom = [
          v.thead(props).$dom
          gclist.views.tbody(props).$dom
        ]
        props
      _.compose(v.layout, gclist.views.table, tableContent)(props)

## Public API

    ns.list = list
