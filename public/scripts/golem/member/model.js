(function () {
  var gm = golem.module;
  gm.member.model = {
    create: function (props) {
      var member = gm.contact.create(props);
      member.schema = 'member';
      member.skills = props.skills || [];
      member.family = false;
      member.cafNumber = props.cafNumber || null;
      member.familyQuotient = props.familyQuotient || null;
      return member;
    },
    fullname: gm.contact.model.fullname,
    fulladdress: gm.family.model.fulladdress
  };
}).call(this);
