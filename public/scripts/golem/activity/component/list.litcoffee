# Activity List

This component represents the listing of activities, a table served with global
and advanced search.

    class List

## Initialization

Here is the component initialization :

* `activities` serves for the global list of all activities. It will be
populated by database as a reactive array.
* `takenPlacesByActivity` will be a reactive map, populated by a db request,
for the sum of all subscribed members by activity
* `filteredActivities` is the list of filtered one, after filter functions has
been applied;
* `activeFilters` contains an map of all active filters : a named field
containing a filter function : for a given item, returning a boolean;

      constructor: ->
        @activities = []
        @takenPlacesByActivity = {}
        @filteredActivities = rx.array()
        @activeFilters = rx.map()

Then we set the document's title and the secondary menu items.

        document.title = golem.utils.title L 'ACTIVITIES_LIST'
        mi = golem.activity.model.data.menuItems
        golem.menus.secondaryItems.replace [mi.list, mi.add]

## List methods

TODO: searches

## Activities

List needs to get `activities`. It uses the db helper function `getBySchema`
for it, passing a callback that displays an `Unexpected` error if a problem
occurs. Otherwise it gets members subscribed for all activities, allowing
display of the taken and remaining places for each.

        golem.model.getBySchema 'activity', (err, res) ->
          if err
            golem.widget.notification.Unexpected content: err
          else
            @activities = rx.array res.rows.map (r) -> new golem.Activity r.doc
            # TODO: use count reduce for this purpose, instead of doing manually
            golem.model.getMembersFromActivity null, (err, res) ->
              if err
                golem.widget.notification.Unexpected content: err
              else
                takenPlacesByActivity = {}
                for r in res.rows
                  aId = r.key[0]
                  takenPlacesByActivity[aId] ?= 0
                  takenPlacesByActivity[aId] += 1
                @takenPlacesByActivity = rx.map takenPlacesByActivity
## List

### Place DOM

`$place` is the function the returns, for a given activity, the span DOM
elementwith an adapted color, according to the remaining places

      $place: (activity) ->
        color = 'inherit'
        if activity.places
          remaining = activity.places - takenPlacesByActivity[activity._id]
          color = switch
            when remaining <= 0 then 'red'
            when remaining < 5 then 'orange'
            else 'green'
        span
          style: { color: color },
          takenPlacesByActivity[activity._id]

### Activity DOM

`$activity` returns the table row corresponding to the given activity.

      $activity: (activity) ->
        tr [
          td activity.label
          td activity.code
          td activity.timeSlot
          td activity.monitor
          td activity.places
          td $place activity
          td { class: 'actions' }, [
            a
              href: '#/activity/show/' + activity._id
              title: L 'VIEW',
              [i { class: 'unhide icon' }]
            a
              href: '#/activity/edit/' + activity._id
              title: L 'EDIT',
              [i { class: 'edit icon' }]
            a
              href: '#/activity/remove/' + activity._id
              title: L 'DELETE',
              [i { class: 'remove icon' }]
          ]
        ]

### Table

The table, with sortable columns into the header.

      $table: ->
        gcL = golem.component.List
        table { class: 'ui basic table' }, [
          thead [
            tr [
              gcL.$sortableTableHeader field: 'label', items: @activities
              gcL.$sortableTableHeader field: 'code', items: @activities
              th L('TIMESLOT')
              gcL.$sortableTableHeader field: 'monitor', items: @activities
              gcL.$sortableTableHeader field: 'places', items: @activities
              th L('PLACES_TAKEN')
              th { width: '10%' }, L('ACTIONS')
            ]
          ]
          tbody do =>
            _items = @filteredActivities or @activities
            _items.map @$activity
        ]

### Global DOM

Finally, a function returning the DOM list corresponding to the component, with
the header and the table. It also inits the list state.

      $list: ->
        [
          section { class: 'twelve wide column' }, [
            golem.menus.$secondary [
              h3 { class: 'ui inverted center aligned purple header' },
                span L 'ACTIVITIES_LIST'
            ]
            @$table()
          ]
          section { class: 'four wide column' }, 'empty atm'
        ]

## Public API

    golem.activity.component.List = List
