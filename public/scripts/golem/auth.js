(function () {
  golem.auth = {
    main: {
      controller: function () {
				var l = golem.utils.locale;
        document.title =  golem.model.title(l('AUTHENTIFICATION'));
				var credentials = {
						login: '8d143618d8af1efbade9dba8b6c93434d98d3da1',
						password: 'db55970eeb626c3e0a00163672ab96aa0ca94572'
				};
				var getHash = function (val) {
					var sha = new jsSHA(val, 'TEXT');
					return sha.getHash('SHA-1', 'HEX');
				};
				var isAuthorized = (function () {
					return (getHash(this.credentials.login()) === credentials.login &&
					  getHash(this.credentials.password()) === credentials.password); 
				}).bind(this);
				this.credentials = { login: m.prop(''), password: m.prop('') };
				this.send = (function (e) {
					e.preventDefault();
					if (!isAuthorized()) {
						golem.utils.sendNotification(
							'Erreur',
							{ body: 'Mot de passe ou identifiant invalides' },
							function () {}
						);
					} else {
						golem.initRouting();
					}
				}).bind(this);
      },
      view: function (ctrl) {
				var l = golem.utils.locale;
        return [
          m('section', { class: 'sixteen wide column' }, [
            m('form', { class: 'ui form', onsubmit: ctrl.send }, [
							m('div.field', [
								m('label', l('LOGIN')),
								m('div', { class: 'ui left labeled icon input' }, [
									m('input', {
										name: 'login',
										type: 'text',
										placeholder: l('LOGIN'),
										value: ctrl.credentials.login(),
					          onchange: m.withAttr('value', ctrl.credentials.login)
									}),
									m('i', { class: 'icon asterisk' })
								])
							]),
							m('div.field', [
								m('label', l('PASSWORD')),
								m('div', { class: 'ui left labeled icon input' }, [
									m('input', {
										name: 'password',
										placeholder: l('PASSWORD'),
										type: 'password',
										value: ctrl.credentials.password(),
					          onchange: m.withAttr('value', ctrl.credentials.password)
									}),
									m('i', { class: 'icon lock' })
								])
							]),
							m('input', {
								class: 'ui blue submit button',
				        type: 'submit',
				        value: l('OK')})
						])
          ])
        ];
				
      }
    },
  };
}).call(this);
