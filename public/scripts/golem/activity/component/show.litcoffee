# Activity show component

This module represents the show page for a given activity.

    ns = golem.module.activity
    notif = golem.component.notification
    show =

## Module launching

As others, the class takes an optional callback as first argument, called with
the whole DOM after all is initialized and a mandatory id, the unique
identifier for the document stored in database. The function creates a partial
`getMembersFromActivity` from the private function, allowing the callback to be
not passed from function to function.

      launch: (callback, id) ->
        show.getMembersFromActivity = _.partial show._getMembersFromActivity,
          callback
        show.getActivity id

`getActivity` checks the validity of the key present into the URL. If there is
an error, it displays it and redirects the user to the list. If not, it creates
an activity reactive object. It needs the `id` of the targetted activity.

      getActivity: (id) ->
        golem.db.get id, (err, res) =>
          if err
            notif.send(notif.warning
              content: L('ERROR_RECORD_NOT_FOUND'),
              displayCb: -> window.location.hash = '#/activity')
          else
            show.setupActivity ns.model.activity(res)

With `setupActivity`, data is retrieved for populating the show page, as the
members subscribed for this activity.

      setupActivity: (activity) ->
        document.title = golem.utils.title(L 'DETAILS' + activity.label.get())
        show.setMenus activity
        show.getMembersFromActivity activity

The title and the secondary menu are created in accordance to the current
activity.

      setMenus: (activity) ->
        mi = ns.model.data.menuItems
        for act in ['show', 'edit', 'remove']
          mi[act].url = "#{mi[act].baseUrl}/#{activity._id.get()}"
        golem.menus.secondaryItems.replace [
          mi.list, mi.add, mi.show, mi.edit, mi.remove
        ]

`getMembersFromActivity` is a private function that returns all members that
have subscribed to the activity, allowing displaying their names and details if
needed. It's not called directly but the launch function creates a partial
version from this with a fixed callback.

      _getMembersFromActivity: (callback, activity) ->
        golem.model.getMembersFromActivity activity._id, (err, res) ->
          if err
            notif.send(notif.unexpected content: err)
            members = []
          else
            members = res.rows.map (r) -> new golem.Member r.doc
          callback(show.views.launch(activity, members)) if callback



## Views

Views use composition : a technique allowing replacement of each component by
another one. For achieving this, every view has a props object they take as
argument and then returns. A special `dom` attribute is used to share the
result, a jQuery DOM element or an array of them, of the precedent component.
Each view should not update the props object, except for the `dom` property.

      views:

`activityMembers` needs a `members` list for listing all members, by their
fullname, who have been subscribed to this activity. A link to their page is
provided.

        activityMembers: (props) ->
          if props.members.length > 0
            props.dom = ul { class: 'ui list' }, props.members.map (member) ->
              li [
                a { href: '#/member/show/' + member._id.get() },
                  member.fullname()
              ]
          else
            props.dom = p L 'NONE'
          props

`activity` consists of the main view, an inline list of fields and values.
It is mainly based on the `activity` but also needs `members`.

        activity: (props) ->
          {activity, members, dom} = props
          props.dom = section { class: 'ui piled segment' }, [
            h2 activity.label.get()
            p activity.note.get()
            div { class: 'ui horizontal list' }, [
              div { class:'item' }, [
                div { class:'content' }, [
                  div { class: 'header' }, L 'CODE'
                  div { class: 'description' }, activity.code.get()
                ]
              ]
              div { class:'item' }, [
                div { class:'content' }, [
                  div { class: 'header' }, L 'TIMESLOT'
                  div { class: 'description' }, activity.timeSlot.get()
                ]
              ]
              div { class:'item' }, [
                div { class:'content' }, [
                  div { class: 'header' }, L 'MONITOR'
                  div { class: 'description' }, activity.monitor.get()
                ]
              ]
              div { class:'item' }, [
                div { class:'content' }, [
                  div { class: 'header' }, L 'PLACES'
                  div { class: 'description' }, activity.places.get()
                ]
              ]
              div { class:'item' }, [
                div { class:'content' }, [
                  div { class: 'header' }, L 'PLACES_TAKEN'
                  div { class: 'description' }, members.length
                ]
              ]
              div { class:'item' }, [
                div { class:'content' }, do =>
                  if activity.places.get()
                    [
                      div { class:'header' }, L 'PLACES_REMAIN'
                      div { class: 'description' },
                        (activity.places.get() - members.length)
                    ]
              ]
            ]
            h3 L 'ACTIVITIES_MEMBERS'
            dom
          ]
          props

`layout` provides the global view, containing the whole activity record and
associated members.

        layout: (props) ->
          {activity, members, dom} = props
          props.dom = [
            section { class: 'sixteen wide column' }, [
              golem.menus.secondary
              dom
            ]
          ]
          props

`launch` is the function that composes all views, for global displaying. It's
the initiator of the shares `props` object between views and it returns the
global DOM object.

        launch: (activity, members) ->
          v = show.views
          fn = _.compose v.layout, v.activity, v.activityMembers
          props = fn activity: activity, members: members
          props.dom


## Public API

    ns.component.show = show
