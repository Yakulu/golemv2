gm = golem.module
gm.member.model =
  create: (props) ->
    member = gm.contact.model.create props
    member.schema = 'member'
    member.number = props.number or null
    member.birthday = props.birthday or null
    member.gender = props.gender or null
    member.nationality = props.nationality or null
    member.profession = props.profession or null
    member.communicationModes = props.communicationModes or
      mail: false
      tel: false
    member.guardianLastname = props.guardianLastname or ''
    member.guardianFirstname = props.guardianFirstname or ''
    member.authorizations = props.authorizations or
      activities: false
      photos: false
    member.skills = props.skills or []
    member.activities = props.activities or []
    #member.family = false;
    #member.cafNumber = props.cafNumber || null;
    #member.familyQuotient = props.familyQuotient || null;
    member
  fullname: gm.contact.model.fullname
  fulladdress: gm.family.model.fulladdress
