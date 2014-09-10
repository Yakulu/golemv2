(function () {
  var gm = golem.module;
  gm.member.model = {
    create: function (props) {
      var member = gm.contact.model.create(props);
      member.schema = 'member';
      member.number = props.number || null;
			member.birthday = props.birthday || null;
			member.gender = props.gender || null;
			member.nationality = props.nationality || null;
			member.profession = props.profession || null;
			member.communicationModes = props.communicationModes || { mail: false, tel: false };
			member.guardianLastname = props.guardianLastname || '';
			member.guardianFirstname = props.guardianFirstname || '';
			member.authorizations = props.authorizations || { activities: false, photos: false };
      member.skills = props.skills || [];
      member.activities = props.skills || [];
      //member.family = false;
      //member.cafNumber = props.cafNumber || null;
      //member.familyQuotient = props.familyQuotient || null;
      return member;
    },
    fullname: gm.contact.model.fullname,
    fulladdress: gm.family.model.fulladdress
  };
}).call(this);
