# Activity Show Component

This class represents the show page for a given activity.

    notif = golem.component.notification

    class Show

## Initialization

First, it checks the validity of the key present into the URL. If there is an
error, it displays it and redirects the user to the list. If not, the activity
data is retrieved for populating the show page, as the members subscribed for
this activity, allowing displaying their names. The secondary menu is created
in accordance to the current view.
As others, the class takes an optional callback as first argument, called with
the whole DOM after all is initialized and a mandatory id, the unique
identifier for the document stored in database.

      constructor: (callback, id) ->
        golem.db.get id, (err, res) =>
          if err
            new notif.Warning content: L('ERROR_RECORD_NOT_FOUND'),
              window.location.hash = '#/activity'
            .send()
          else
            @activity = new golem.Activity res
            document.title = golem.utils.title(L 'DETAILS' + @activity.label)
            mi = golem.activity.model.data.menuItems
            for act in ['show', 'edit', 'remove']
              mi[act].url = "#{mi[act].baseUrl}/#{@activity._id.get()}"
            golem.menus.secondaryItems.replace [
              mi.list, mi.add, mi.show, mi.edit, mi.remove
            ]
            golem.model.getMembersFromActivity @activity._id, (err, res) =>
              if err
                new notif.Unexpected(content: err).send()
                @members = []
              else
                @members = res.rows.map (r) -> new golem.Member r.doc
              callback(@$view()) if callback

## Views

`$activityMembers` lists all members, by their fullname, who have been
subscribed to this activity. A link to their page is provided.

      $activityMembers: =>
        if @members.length > 0
          ul { class: 'ui list' }, @members.map (member) ->
            li [
              a { href: '#/member/show/' + member._id.get() },
                member.fullname()
            ]
        else
          p L 'NONE'

`$activity` consists of the main view, an inline list of fields and values.

      $activity: =>
        section { class: 'ui piled segment' }, [
          h2 @activity.label.get()
          p @activity.note.get()
          div { class: 'ui horizontal list' }, [
            div { class:'item' }, [
              div { class:'content' }, [
                div { class: 'header' }, L 'CODE'
                div { class: 'description' }, @activity.code.get()
              ]
            ]
            div { class:'item' }, [
              div { class:'content' }, [
                div { class: 'header' }, L 'TIMESLOT'
                div { class: 'description' }, @activity.timeSlot.get()
              ]
            ]
            div { class:'item' }, [
              div { class:'content' }, [
                div { class: 'header' }, L 'MONITOR'
                div { class: 'description' }, @activity.monitor.get()
              ]
            ]
            div { class:'item' }, [
              div { class:'content' }, [
                div { class: 'header' }, L 'PLACES'
                div { class: 'description' }, @activity.places.get()
              ]
            ]
            div { class:'item' }, [
              div { class:'content' }, [
                div { class: 'header' }, L 'PLACES_TAKEN'
                div { class: 'description' }, @members.length
              ]
            ]
            div { class:'item' }, [
              div { class:'content' }, do =>
                if @activity.places.get()
                  [
                    div { class:'header' }, L 'PLACES_REMAIN'
                    div { class: 'description' },
                      (@activity.places.get() - @members.length)
                  ]
            ]
          ]
          h3 L 'ACTIVITIES_MEMBERS'
          @$activityMembers()
        ]

`$view` provides the global view, containing the whole activity record and
associated members.

      $view: =>
        [
          section { class: 'sixteen wide column' }, [
            golem.menus.$secondary
            @$activity()
          ]
        ]

## Public API

    golem.activity.component.Show = Show
