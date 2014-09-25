# Member list

This component is the list of member, composed by a table, an advanced search
and filters on the right sidebar. It inherits from `golem.component.List`.

    notif = golem.component.notification
    ns = golem.module.member
    class List extends golem.component.List

## Initialization

The List makes a call to its parent for initialization.

      constructor: ->
        window.gList = @
        super()

Then we set the document's title and the secondary menu items.

        document.title = golem.utils.title L 'MEMBERS_LIST'
        mi = ns.model.data.menuItems
        golem.menus.secondaryItems.replace [mi.list, mi.add, mi.tags, mi.skills]

### Members

Here is the initial population of `\_items` and `items properties`, from the
database helper `getBySchema`.

        golem.model.getBySchema 'member', (err, res) =>
          if err
            notif.send(notif.unexpected content: err)
          else
            @_items = res.rows.map (r) -> ns.model.member r.doc
            @items.replace @_items

## List Views

### Member row

`memberView` is a method that returns the table row corresponding to the given
item.

      memberView: (item) ->
        tr [
          td item.number.get()
          td ns.model.fullname(item).get()
          td ns.model.fulladdress(item).get()
          td item.tels.all().forEach (t) ->
            if t.default
              t.value.match(/\d{2}/g).join '.'
          td item.mails.all().forEach (mail) ->
            if mail.default
              a { href: 'mailto:' + mail.value }, mail.value
          td { class:'actions' }, [
            a
              href: '#/member/show/' + item._id.get()
              title: L('VIEW'),
              [i { class: 'unhide icon' }]
            a
              href: '#/member/edit/' + item._id.get()
              title: L('EDIT'),
              [i { class: 'edit icon' }]
            a
              href: '#/member/remove/' + item._id.get()
              title: L('DELETE')
              [i { class: 'remove icon' }]
          ]
        ]

### Table

The `table`, with sortable columns into the header.

      table: ->
        table { class: 'ui basic table' }, [
          thead [
            tr [
              @sortableTableHeader field: 'number', title: 'MEMBER_NUMBER'
              @sortableTableHeader field: 'lastname'
              @sortableTableHeader field: 'city', title: 'ADDRESS'
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
          tbody @items.map @memberView
        ]

### Right Sidebar

      sidebar: -> nav()

### Global View

Finally, a function returning the DOM list corresponding to the component, with
the header and the table.

      view: ->
        [
          section { class: 'twelve wide column' }, [
            golem.menus.secondary
            golem.component.common.headerExpandable
              class: 'inverted center aligned black'
              title: L 'SEARCH_ADVANCED'
              active: @searchAdvancedOn
            p bind => if @searchAdvancedOn.get() then @advancedSearch() else ''
            h3 { class: 'ui inverted center aligned purple header' },
              span L 'MEMBERS_LIST'
            @table()
          ]
          section { class: 'four wide column' }, @sidebar()
        ]

## Public API

    ns.component.List = List
