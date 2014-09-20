# Common component list

This class gathers helpers and subcomponents shared by many list components.

    class List

## Helpers

`sort` static property takes as arguments a field name and the item's list. It
performs a simple sorting. If the list has already been sorted, it's reversed.

      @sort = (field, items) ->
        rawItems = items.all()
        if field
          first = rawItems[0]
          rawItems.sort (a, b) ->
            switch
              when a[field] > b[field] then 1
              when b[field] > a[field] then -1
              else 0
          rawItems.reverse() if first is rawItems[0]
        items.replace rawItems

`$sortableTableHeader` is a component taking a config object :

* the `field` intended for sorting the list;
* the `title` for the table header, optional, default to the locale field
uppercased;
* the `items` list, for passing to the sort function

It returns a _th_ DOM object with bound events, like `mouseover` and `mouseout`
displaying an icon for sorting comprehension and the `click` event for sorting.

      @$sortableTableHeader = (config) ->
        title = config.title or config.field.toUpperCase()
        th
          class: 'sortable'
          click: List.sort.bind(null, config.field, config.items),
          [
            span L(title)
            i class: 'icon sort'
          ]

## Public API

    golem.component.List = List
