# Member list

This component is the list of member, composed by a table, an advanced search
and filters on the right sidebar. It used `golem.component.list`.

    notif = golem.component.notification
    ns = golem.module.member
    gclist = golem.component.list

    list =

## Module initialization and launch

The list makes :

- a call to its parent for initialization;
- run setup function;
- calls the asynchronous `getMembers` function with `finish`, and so renders,
  as callback.

      launch: (callback) ->
        props = gclist.init ns, callback
        list.setup()
        list.getMembers props, list.finish

Then we set the document's title and the secondary menu items.

      setup: ->
        document.title = golem.utils.title L 'MEMBERS_LIST'
        mi = ns.model.data.menuItems
        golem.menus.secondaryItems.replace [mi.list, mi.add, mi.tags, mi.skills]

### Members

Here is the initial population of `\_items` and `items` properties, from the
database helper `getBySchema`. An `callback`, has to be passed and then is
launched with props as first argument.

      getMembers: (props, callback) ->
        golem.model.getBySchema 'member', (err, res) ->
          if err
            notif.send(notif.unexpected content: err)
          else
            props._items = res.rows.map (r) -> ns.model.member r.doc
            props.items.replace props._items
          callback props

## List Views

      views:

### Member DOM

`member` is a method that returns the table row corresponding to the given
item.

        member: (props, member) ->
          id = member._id.get()
          tr [
            td member.number.get()
            td ns.model.fullname(member).get()
            td ns.model.fulladdress(member).get()
            td member.tels.all().forEach (t) ->
              if t.default
                t.value.match(/\d{2}/g).join '.'
            td member.mails.all().forEach (mail) ->
              if mail.default
                a { href: 'mailto:' + mail.value }, mail.value
            td { class:'actions' }, [
              a
                href: "#/member/show/#{id}"
                title: L('VIEW'),
                [i { class: 'unhide icon' }]
              a
                href: "#/member/edit/#{id}"
                title: L('EDIT'),
                [i { class: 'edit icon' }]
              a
                href: "#/member/remove/#{id}"
                title: L('DELETE')
                [i { class: 'remove icon' }]
            ]
          ]

### Table header

`thead` table header, with sortable columns.

        thead: (props) ->
          sthProps =
            sortFn: props.sortFn
            items: props.items
          sth = gclist.components.sortableTableHeader
          props.$dom = thead [
              tr [
                sth(_.defaults(
                  sthProps
                  field: 'number', title: 'MEMBER_NUMBER')).$dom
                sth(_.defaults sthProps, field: 'lastname').$dom
                sth(_.defaults(
                  sthProps
                  field: 'city', title: 'ADDRESS')).$dom
                th [
                  span L 'TEL'
                  i { class: 'icon info', title: L 'DEFAULT_ONLY' }
                ]
                th [
                  span L 'MAIL'
                  i { class: 'icon info', title: L 'DEFAULT_ONLY' }
                ]
                th { width: '10%' }, L 'ACTIONS'
              ]
            ]
          props

### Right Sidebar

        sidebar: (props) ->
          props.$dom = nav()
          props

### Global DOM

Finally, a function returning the DOM list corresponding to the component, with
the header and the table.

        layout: (props) ->
          searchAdv = props.searchAdvancedOn
          props.$dom = [
            section { class: 'twelve wide column' }, [
              golem.menus.secondary
              golem.component.common.headerExpandable
                class: 'inverted center aligned black'
                title: L 'SEARCH_ADVANCED'
                active: searchAdv
              p bind ->
                if searchAdv.get()
                  list.views.advancedSearch(props).$dom
                else
                  ''
              h3 { class: 'ui inverted center aligned purple header' },
                span L 'MEMBERS_LIST'
              props.$dom
            ]
            section { class: 'four wide column' },
              list.views.sidebar(props).$dom
          ]
          props

## Components

      components:

`list` is the unique component of this page, composing all views and passing to
them the `props` objects, updated to add mandatory functions in our situation.

        list: (props) ->
          props.sortFn = gclist.sort
          props.rowFn = list.views.member
          v = list.views
          tableContent = (props) ->
            props.$dom = [
              v.thead(props).$dom
              gclist.views.tbody(props).$dom
            ]
            props
          _.compose(v.layout, gclist.views.table, tableContent)(props)

## Public API

    ns.component.list = list
