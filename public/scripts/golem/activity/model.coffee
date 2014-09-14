gm = golem.module
gm.activity.model =
  create: (props) ->
    props ?= {}
    return { schema: 'activity'
    creationDate: Date.now()
    label: props.label or ''
    code: props.code or ''
    timeSlot: props.timeSlot or ''
    monitor: props.monitor or ''
    places: props.places or null
    note: props.note or '' }

  fullLabel: (a) -> if a.code then "#{a.code} #{a.label}" else a.label
  # TODO : full, remainingPlaces, number of subscribers etc
