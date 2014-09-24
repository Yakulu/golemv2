# Common component list

This class gathers helpers and subcomponents shared by many list components.

    class List

## Initialization

All List components may need to show `items` and some kind of `filters` and
`searches`. Here we initilialize the component :

- `\_items` serves for the global list of all items. It will be populated by
  database as an array.
- `items`  is the current list, filtered or not, that will be populated from
  the private \_items property the first time and every time filters are
  emptied.
- `filters` contains an map of all active filters : a named field containing a
  filter function : for a given item, returning a boolean;
- `searchAdvancedOn` is a simple reactive boolean for injecting or not the
  advanced search DOM at the top of the list
- `searches` is a reactive map containing searches values from the advanced
  search form. It's used in conjonction with `filters`.

      constructor: ->
        @_items = []
        @items = rx.array()
        @filters = rx.map()
        @searchAdvancedOn = rx.cell false
        @searches = rx.map()

## Helpers

### Function Helpers

#### sort

`sort` function takes as argument a field name. It performs a simple sorting.
If the list has already been sorted, it's reversed.

      sort: (field) =>
        first = @items.at 0
        sortedItems = _.sortBy @items.all(), (item) -> item[field].get()
        sortedItems.reverse() if first is sortedItems[0]
        @items.replace sortedItems

#### filter

The `filter` helper is quite simple : using the native array of items and
the reactive map of filters in values, it applies all the filters for each item
and returns the filetered set, a native JS Array.

      filter: ->
        return [] if @_items.length is 0
        @_items.filter (item) =>
          for fn in _(@filters.all()).values()
            return false unless fn item
          true

#### search

`@searchJSON` is a static helper that provides a simple way of looking full text
around all given items.
WARNING: it is slow because it uses an `indexOf` on a JSON version of the
object !

      @searchJSON: (value, item) ->
        json = JSON.stringify(item).toLowerCase()
        json.indexOf(value.toLowerCase()) isnt -1

### View Static Helpers

#### $search

`@$search` is a static function representing a component for the context menu,
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

- the `field` intended for sorting the list;
- the `title` for the table header, optional, default to the locale field
  uppercased;
- the `items` list, for passing to the sort function

It returns a _th_ DOM object with bound events, like `mouseover` and `mouseout`
displaying an icon for sorting comprehension and the `click` event for sorting.

      $sortableTableHeader: (config) ->
        title = config.title or config.field.toUpperCase()
        th
          class: 'sortable'
          click: @sort.bind(@, config.field),
          [
            span L(title)
            i class: 'icon sort'
          ]

## Public API

    golem.component.List = List
