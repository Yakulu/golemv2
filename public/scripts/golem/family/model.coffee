gm = golem.module
gm.family.model =
  create: (props) ->
    props ?= {}
    return { schema: 'family'
    creationDate: Date.now()
    lastname: props.lastname or ''
    address: props.address or ''
    postalCode: props.postalCode or ''
    city: props.city or ''
    note: props.note or ''
    tels: props.tels or []
    mails: props.mails or []
    www: props.www or []
    movements: props.movements or [] }

  fulladdress: (f) -> [f.address, f.postalCode, f.city].join ' '
