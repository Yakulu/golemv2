# TODO : full, remainingPlaces, number of subscribers etc
class golem.Activity extends golem.Doc

  constructor: (props) ->
    super props
    unless @_id
      props = {}
      @schema = 'activity'
      @creationDate = Date.now()
      @label = props.label or ''
      @code = props.code or ''
      @timeSlot = props.timeSlot or ''
      @monitor = props.monitor or ''
      @places = props.places or null
      @note = props.note or ''

  fullLabel: -> if @code then "#{@code} #{@label}" else @label
