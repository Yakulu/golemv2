# Member Model

## Member class

### Initialization

A `Member` takes a `props` object with :

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

It inherits from `golem.Doc`. If no identifier is provided, then we create a
new document and initalize all defaults, including the `schema` and the Date of
creation of the instance.  Lifting is done to enable precise reactivity.

    class golem.Member extends golem.Doc
      constructor: (props) ->
        super props
        unless @_id
          props ?= {}
          @schema = 'member'
          @creationDate = Date.now()
          nullFields = ['firstname', 'lastname', 'number', 'birthday', 'gender',
            'address', 'postalCode', 'city', 'nationality', 'profession',
            'note', 'guardianLastname', 'guardianFirstname' ]
          for field in nullFields
            @[field] = props[field] or null
          for field in ['tels', 'mails', 'tags', 'skills']
            @[field] = props[field] or []
          @communicationModes = props.communicationModes or
            mail: false
            tel: false
          @authorizations = props.authorizations or
            activities: false
            photos: false
          rx.lift @

### Methods

`fullname`, `fulladdress` and `fullguardian` are all helpers for displaying the
merge of several fields.

      fullname: -> "#{@firstname.get()} #{@lastname.get()}"
      fullguardian: -> "#{@guardianFirstname.get()} #{@guardianLastname.get()}"
      fulladdress: -> [@address.get(), @postalCode.get(), @city.get()].join ' '

## MenuItems

Here are the items for the secondary menu. Module will pick into them for
displaying.

    Menu = golem.menus.Menu
    menuItems =
      list: new Menu L('LIST'), '/member', 'list'
      add: new Menu L('NEW'), '/member/add', 'add sign'
      show: new Menu L('VIEW'), '/member/show', 'search'
      edit: new Menu L('EDIT'), '/member/edit', 'edit'
      remove: new Menu L('DELETE'), '/member/remove', 'remove'
      skills: new Menu L('SKILLS'), '/member/skills', 'briefcase'
      tags: new Menu L('TAGS'), '/member/tags', 'tags'

## Public API

    golem.member.model =
      data:
        items: []
        menuItems: menuItems
