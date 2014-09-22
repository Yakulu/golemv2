# Activity List

This component represents the listing of activities, a table served with global
and advanced search.

    class List extends golem.component.List

## Initialization

Here is the component initialization :

* `\_activities` serves for the global list of all activities. It will be
populated by database as an array.
* `activities`  is the current list, fitlered or not, that will be populated
* from the private \_activities property the first time and every time filters
are emptied.
* `takenPlacesByActivity` will be a reactive map, populated by a db request,
for the sum of all subscribed members by activity
* `filteredActivities` is the list of filtered one, after filter functions has
been applied;
* `filters` contains an map of all active filters : a named field
containing a filter function : for a given item, returning a boolean;
* `searchAdvancedOn` is a simple reactive boolean for injecting or not the
avdanced search DOM at the top of the list
* `searches` is a reactive map containing searches values from the advanced
search form. It's used in conjonction with `filters`.

      constructor: ->
        window.gList = @
        @_activities = []
        @activities = rx.array()
        @takenPlacesByActivity = rx.map()
        @filters = rx.map()
        @searchAdvancedOn = rx.cell false
        @searches = rx.map(label: '', code: '', monitor: '')

Then we set the document's title and the secondary menu items.

        document.title = golem.utils.title L 'ACTIVITIES_LIST'
        mi = golem.activity.model.data.menuItems
        golem.menus.secondaryItems.replace [mi.list, mi.add]

## Activities

List needs to get `activities`. It uses the db helper function `getBySchema`
for it, passing a callback that displays an `Unexpected` error if a problem
occurs. Otherwise it gets members subscribed for all activities, allowing
display of the taken and remaining places for each.

        golem.model.getBySchema 'activity', (err, res) =>
          if err
            golem.component.notification.Unexpected content: err
          else
            @_activities = res.rows.map (r) -> new golem.Activity r.doc
            @activities.replace @_activities
            # TODO: use count reduce for this purpose, instead of doing manually
            golem.model.getMembersFromActivity null, (err, res) =>
              if err
                golem.component.notification.Unexpected content: err
              else
                takenPlacesByActivity = {}
                for r in res.rows
                  aId = r.key[0]
                  takenPlacesByActivity[aId] ?= 0
                  takenPlacesByActivity[aId] += 1
                @takenPlacesByActivity.update takenPlacesByActivity

## List methods

### Global search

`searchGlobal` is a function that employs the component common `search` helper
to provide a full text, but slow, research in all activities. The search
function is called only if the search input is valid.

      searchGlobal: (e) =>
        if e.target.checkValidity()
          @filters.put 'search', List.search.bind(null, e.target.value)
        else
          @filters.remove 'search' if @filters.get 'search'
        @activities.replace(List.filter @_activities, @filters)

### Advanced search

`searchAdvanced` takes a `reset` boolean as first argument. If reset is true,
the function makes all `searches` empty and removes the corresponding `filters`
if they exist. Otherwise, it removes the filter only if the value of the search
is empty and add the filters on `filters` if the value has been filled. The
second argument, `e` is the jQuery event for the form submission. It's only
here for preventing default behavior.

      searchAdvanced: (reset, e) =>
        e.preventDefault()
        _.chain(@searches.all()).keys().each (field) =>
          unless reset
            if @searches.get(field).length is 0
              @filters.remove field if @filters.get field
            else
              value = @searches.get(field).toLowerCase()
              @filters.put field, (item) ->
                item[field].get().toLowerCase().indexOf(value) isnt -1
          else
            @searches.put field, ''
            @filters.remove field if @filters.get field
        @activities.replace(List.filter @_activities, @filters)

## List Views

### Advanced Search DOM

`$avdancedSearch` is a form witch contains all fields where a user can search
to filter the activities list. Each search can be cumulated, thanks to
`filters` instance method. Search is submitted via a send button and can be
globally canceled via a cancel button.

      $advancedSearch: =>
        form
          class: 'ui small form'
          submit: @searchAdvanced.bind(@, false),
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
                value: bind => @searches.get 'label'
                keyup: (e) => @searches.put 'label', e.target.value
              input
                class: 'two wide column field input'
                type: 'text'
                name: 'code'
                placeholder: L 'CODE'
                maxlength: 30
                value: bind => @searches.get 'code'
                keyup: (e) => @searches.put 'code', e.target.value
              input
                class: 'four wide column field input'
                type: 'text'
                name: 'monitor'
                placeholder: L 'MONITOR'
                maxlength: 50
                value: bind => @searches.get 'monitor'
                keyup: (e) => @searches.put 'monitor', e.target.value
              div { class: 'ui buttons' }, [
                input
                  class: 'ui green small submit button'
                  type: 'submit'
                  value: L 'OK'
                button
                  name: 'cancel'
                  class: 'ui small button'
                  type: 'button'
                  click: @searchAdvanced.bind(@, true),
                  L 'CANCEL'
              ]
            ]
          ]

### Place DOM

`$place` is the property, a function which returns, for a given activity, the
span DOM elementwith an adapted color, according to the remaining places

      $place: (activity) =>
        color = 'inherit'
        if activity.places.get()
          takenPlaces = @takenPlacesByActivity.get(activity._id.get())
          remain = activity.places.get() - takenPlaces
          color = switch
            when remain <= 0 then 'red'
            when remain < 5 then 'orange'
            else 'green'
        span
          style: { color: color },
          @takenPlacesByActivity.get(activity._id.get()) or 0

### Activity DOM

`$activity` is a method that returns the table row corresponding to the given
activity.

      $activity: (activity) =>
        tr [
          td activity.label.get()
          td activity.code.get()
          td activity.timeSlot.get()
          td activity.monitor.get()
          td activity.places.get()
          td @$place activity
          td { class: 'actions' }, [
            a
              href: '#/activity/show/' + activity._id.get()
              title: L('VIEW'),
              [i { class: 'unhide icon' }]
            a
              href: '#/activity/edit/' + activity._id.get()
              title: L('EDIT'),
              [i { class: 'edit icon' }]
            a
              href: '#/activity/remove/' + activity._id.get()
              title: L('DELETE'),
              [i { class: 'remove icon' }]
          ]
        ]

### Table

The `$table`, with sortable columns into the header.

      $table: ->
        table { class: 'ui basic table' }, [
          thead [
            tr [
              List.$sortableTableHeader field: 'label', items: @activities
              List.$sortableTableHeader field: 'code', items: @activities
              th L('TIMESLOT')
              List.$sortableTableHeader field: 'monitor', items: @activities
              List.$sortableTableHeader field: 'places', items: @activities
              th L('PLACES_TAKEN')
              th { width: '10%' }, L('ACTIONS')
            ]
          ]
          tbody @activities.map @$activity
        ]

### Right Sidebar

      $sidebar: ->
        nav [
          menu { class: 'ui small vertical menu' },
            List.$search @searchGlobal, { pattern: '.{4,}' }
        ]

### Global DOM

Finally, a function returning the DOM list corresponding to the component, with
the header and the table. It also inits the list state.

      $list: ->
        [
          section { class: 'twelve wide column' }, [
            golem.menus.$secondary
            golem.component.common.$headerExpandable
              class: 'inverted center aligned black'
              title: L 'SEARCH_ADVANCED'
              active: @searchAdvancedOn
            p bind => if @searchAdvancedOn.get() then @$advancedSearch() else ''
            h3 { class: 'ui inverted center aligned purple header' },
              span L 'ACTIVITIES_LIST'
            @$table()
          ]
          section { class: 'four wide column' }, @$sidebar()
        ]

## Public API

    golem.activity.component.List = List
