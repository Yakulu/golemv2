(function () {
  golem.auth = {
    main: {
      controller: function () {
        var me = this;
				var l = golem.config.locale;
        document.title =  golem.utils.title(l.AUTHENTIFICATION);
				var credentials = {
						login: '8d143618d8af1efbade9dba8b6c93434d98d3da1',
						password: 'db55970eeb626c3e0a00163672ab96aa0ca94572'
				};
				var getHash = function (val) {
					var sha = new jsSHA(val, 'TEXT');
					return sha.getHash('SHA-1', 'HEX');
				};
				var isAuthorized = function (login, password) {
					return (getHash(login) === credentials.login && getHash(password) === credentials.password); 
				};
				me.send = function (e) {
					e.preventDefault();
					var login = document.getElementsByName('login')[0].value;
					var password = document.getElementsByName('password')[0].value;
					if (!isAuthorized(login, password)) {
						golem.utils.sendNotification(
              {
                cls: 'error',
                icon: 'attention',
                title: l.ERROR,
                body: 'Mot de passe ou identifiant invalides'
              }
						);
					} else {
						golem.initRouting();
					}
				};
      },
      view: function (ctrl) {
				var l = golem.config.locale;
        return [
          m('section', { class: 'sixteen wide column' }, [
            m('form', { class: 'ui form', onsubmit: ctrl.send }, [
							m('div.field', [
								m('label', l.LOGIN),
								m('div', { class: 'ui left labeled icon input' }, [
									m('input', {
										name: 'login',
										type: 'text',
										placeholder: l.LOGIN
									}),
									m('i', { class: 'icon asterisk' })
								])
							]),
							m('div.field', [
								m('label', l.PASSWORD),
								m('div', { class: 'ui left labeled icon input' }, [
									m('input', {
										name: 'password',
										placeholder: l.PASSWORD,
										type: 'password'
									}),
									m('i', { class: 'icon lock' })
								])
							]),
							m('input', {
								class: 'ui blue submit button',
				        type: 'submit',
				        value: l.OK})
						])
          ])
        ];
				
      }
    },
  };
}).call(this);
