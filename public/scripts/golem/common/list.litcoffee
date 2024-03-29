# List common

This common gathers helpers and subcomponents shared by many list components.

    list = {}

## Initialization

All List commons may need to show `items` and some kind of `filters` and
`searches`. Here we initilialize the common :

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

The init function takes optional `ns` and `callback` arguments to create a
namespaced finish function if there is a callback to call.

    list.init = (ns, callback) ->
      props =
        _items: []
        items: rx.array()
        filters: rx.map()
        searchAdvancedOn: rx.cell false
        searches: rx.map()
      finish = (callback, props) ->
        props = list.render ns, props
        callback props.$dom
      ns.list.finish = _.partial finish, callback if callback
      props

## Helpers

### Function Helpers

#### render

`render` launched the rendering when all data has been gathered. This function
serves to define `finish` function if there is a callback.

    list.render = (ns, props) -> ns.list.components.list props

#### sort

`sort` function takes as argument a field name and the concerned reactive
items. It performs a simple sorting. If the list has already been sorted, it's
reversed.

    list.sort = (field, items) =>
      first = items.at 0
      sortedItems = _.sortBy items.all(), (item) -> item[field].get()
      sortedItems.reverse() if first is sortedItems[0]
      items.replace sortedItems

#### filter

The `filter` helper is quite simple : using the native array of items and
the reactive map of filters in values, it applies all the filters for each item
and returns the filetered set, a native JS Array.

    list.filter = (filters, rawItems) ->
      return [] if rawItems.length is 0
      rawItems.filter (item) =>
        for fn in _(filters.all()).values()
          return false unless fn item
        true

#### search

`searchJSON` is an helper that provides a simple way of looking full text
around all given items.
WARNING: it is slow because it uses an `indexOf` on a JSON version of the
object !

    list.searchJSON = (value, item) ->
      json = JSON.stringify(item).toLowerCase()
      json.indexOf(value.toLowerCase()) isnt -1

### View Static Helpers

All are composable with the special `props` argument and `dom` computed result.

    list.views = {}

#### search views

`search` represents the DOM around the search elements.

    list.views.search = (props) ->
      props.$dom = [
        div { class: 'header item' }, [
          span L('SEARCH_GLOBAL')
          i { class: 'warning icon', title: L('SEARCH_GLOBAL_WARNING') }
        ]
        div { class: 'item' }, [
          div { class: 'ui small icon input' }, [
            props.$dom
            i class: 'unhide icon'
          ]
        ]
      ]
      props

`searchInput` returns an search input with a `searchFn` function called each
time a keystroke is done. Validation of this field comes from HTML5 `inputAttr`
property attributes.

    list.views.searchInput = (props) ->
      {searchFn, inputAttr} = props
      _.defaults inputAttr,
        type: 'search'
        placeholder: L 'TYPE_HERE'
        title: L 'SEARCH_ERROR_TOO_SHORT'
        keyup: searchFn
        blur: searchFn
      props.$dom = input inputAttr
      props


`tbody` represents all activities, one per row.

    list.views.tbody = (props) ->
      props.$dom = tbody props.items.map _.partial(props.rowFn, props)
      props

`table` with sortable columns into the header.

    list.views.table = (props) ->
      props.$dom = table { class: 'ui basic table' }, props.$dom
      props

### Components

Components are the glu between composable views.

    list.components = {}

#### Search component

`search` is a view function representing a component for the context menu,
providing a global search for a list. It returns the `props`, including the
generated DOM.

    list.components.search = (props) ->
      _.compose(list.views.search, list.views.searchInput)(props)

#### sortableTableHeader component

`sortableTableHeader` is a component taking on the `props` object :

- the `field` intended for sorting the list;
- the `title` for the table header, optional, default to the locale field
uppercased;
- the `items` list, for passing to the sort function
- and the `sortFn` function

It returns the `props` object, including _th_ `dom` object with bound events,
like `mouseover` and `mouseout` displaying an icon for sorting comprehension
and the `click` event for sorting.

    list.components.sortableTableHeader = (props) ->
      title = props.title or props.field.toUpperCase()
      props.$dom = th
        class: 'sortable'
        click: _.partial(props.sortFn, props.field, props.items),
        [
          span L(title)
          i class: 'icon sort'
        ]
      props

## Public API

    golem.common.list = list
