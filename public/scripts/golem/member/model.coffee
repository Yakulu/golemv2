gm = golem.module

class golem.Member extends golem.Doc

  constructor: (props) ->
    super props
    unless @_id
      props = {}
      @[k] = v for k, v of new golem.Contact()
      @schema = 'member'
      @number = props.number or null
      @birthday = props.birthday or null
      @gender = props.gender or null
      @nationality = props.nationality or null
      @profession = props.profession or null
      @communicationModes = props.communicationModes or mail: false, tel: false
      @guardianLastname = props.guardianLastname or ''
      @guardianFirstname = props.guardianFirstname or ''
      @authorizations = props.authorizations or
        activities: false
        photos: false
      @skills = props.skills or []
      @activities = props.activities or []

  fullname: -> "#{@firstname} #{@lastname}"
  fulladdress: -> gm.family.model.fulladdress.call null, this
  fullguardian: -> "#{@guardianLastname} #{@guardianFirstname}"
