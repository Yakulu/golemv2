# Member Model

    model = {}

## Initialization

A `member` takes a `props` object with :

- `number`, optional home made identifier for the member;
- `birthday` a JS Date Object, default to null;
- `gender` an enum like string, 'f' for female and 'm' for male, default to
  null;
- `address`, a string default to null;
- `postalCode`, a string of 5 numeric, default to null;
- `city`, a string default to null;
- `nationality`, a string default to null;
- `profession` string, default to null;
- `note`, a big string default to null;
- `communicationModes`, an object with keys `mail` and `tel`, by defaults fixed
  both to false;
- `guardianLastname`, a string for the child's guardian lastname;
- `guardianFirstname`, a string for the child's guardian firstname;
- `authorizations` for children, an object to confirm the possibility to
  participate and to be taken in photos, default to false both;
- `tels`, an array of objects, each with a label, value strings and a default
  boolean option;
- `mails`, an array of objects, each with a label, value strings and a default
  boolean option;
- `skills`, an array of strings, default to empty;
- `tags`, an array of strings, default to empty;
- `activities`, an array of strings, the documents identifiers of subscribed
  Activities, default to empty.

If `props` is empty and has no identifier, member is initialized only with
defaults. If not, defaults are only fixed if not present. Lifting is done to
enable precise reactivity.

    model.member = (props) ->
      me = props or {}
      unless me._id
        me.schema ?= 'member'
        me.creationDate ?= Date.now()
        nullFields = ['firstname', 'lastname', 'number', 'birthday', 'gender',
          'address', 'postalCode', 'city', 'nationality', 'profession',
          'note', 'guardianLastname', 'guardianFirstname' ]
        for field in nullFields
          me[field] ?= null
        for field in ['tels', 'mails', 'tags', 'skills']
          me[field] ?= []
        me.communicationModes ?= mail: false, tel: false
        me.authorizations ?= activities: false, photos: false
      rx.lift me

## Methods

`fullname`, `fulladdress` and `fullguardian` are all on demand dependent cells
helpers for displaying the merge of several fields.

    model.fullname = (m) ->
      bind -> "#{m.firstname.get()} #{m.lastname.get()}"
    fullguardian = (m) ->
      bind -> "#{m.guardianFirstname.get()} #{m.guardianLastname.get()}"
    fulladdress = (m) ->
      bind -> [m.address.get(), m.postalCode.get(), m.city.get()].join ' '

# MenuItems

Here are the items for the secondary menu. Module will pick into them for
displaying.

    model.data = {}
    menuitem = golem.menus.item
    model.data.menuItems =
      list: menuitem L('LIST'), '/member', 'list'
      add: menuitem L('NEW'), '/member/add', 'add sign'
      show: menuitem L('VIEW'), '/member/show', 'search'
      edit: menuitem L('EDIT'), '/member/edit', 'edit'
      remove: menuitem L('DELETE'), '/member/remove', 'remove'
      skills: menuitem L('SKILLS'), '/member/skills', 'briefcase'
      tags: menuitem L('TAGS'), '/member/tags', 'tags'

# Public API

    golem.module.member.model = model
