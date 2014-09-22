# Common component list

This class gathers helpers and subcomponents shared by many list components.

    class List

## Helpers

### Function Helpers

#### sort

`@sort` static property takes as arguments a field name and the item's list. It
performs a simple sorting. If the list has already been sorted, it's reversed.

      @sort: (field, items) ->
        rawItems = items.all()
        if field
          first = rawItems[0]
          rawItems.sort (a, b) ->
            switch
              when a[field].get() > b[field].get() then 1
              when b[field].get() > a[field].get() then -1
              else 0
          rawItems.reverse() if first is rawItems[0]
        items.replace rawItems

#### filter

The `filter` static helper is quite simple : given a  native array of items and
a reactive map of filters in values, it applies all the filters for each item
and returns the filetered set, a native JS Array.

      @filter: (items, filters) ->
        return [] if items.length is 0
        items.filter (item) ->
          for fn in _(filters.all()).values()
            return false unless fn item
          true

#### search

`@search` is a static helper that provides a simple way of looking full text
around all given items. WARNING: it is slow because it uses an `indexOf` on a
JSON version of the object !

      @search: (value, item) ->
        json = JSON.stringify(item).toLowerCase()
        json.indexOf(value.toLowerCase()) isnt -1

### View Helpers

### $search

`@$search` is a static method representing a component for the context menu,
providing a global search for a list. Its first argument is a `searchFn`
function, called at each keystroke if the input field is valid. Validation of
this field is provided by HTML5 `inputAttr` attributes, merged from the second
argument.


      @$search: (searchFn, inputAttr) ->
        _.defaults inputAttr,
          type: 'search'
          placeholder: L 'TYPE_HERE'
          title: L 'SEARCH_ERROR_TOO_SHORT'
          keyup: searchFn
          blur: searchFn
        [
          div { class: 'header item' }, [
            span L('SEARCH_GLOBAL')
            i { class: 'warning icon', title: L('SEARCH_GLOBAL_WARNING') }
          ]
          div { class: 'item' }, [
            div { class: 'ui small icon input' }, [
              input inputAttr
              i class: 'unhide icon'
            ]
          ]
        ]


#### $sortableTableHeader

`@$sortableTableHeader` is a static property, a component taking a config
object :

* the `field` intended for sorting the list;
* the `title` for the table header, optional, default to the locale field
uppercased;
* the `items` list, for passing to the sort function

It returns a _th_ DOM object with bound events, like `mouseover` and `mouseout`
displaying an icon for sorting comprehension and the `click` event for sorting.

      @$sortableTableHeader: (config) ->
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
