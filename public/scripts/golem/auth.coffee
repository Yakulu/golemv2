golem.auth =
  main:
    controller: ->
      l = golem.config.locale
      document.title = golem.utils.title l.AUTHENTIFICATION
      credentials =
        login: '8d143618d8af1efbade9dba8b6c93434d98d3da1'
        password: 'db55970eeb626c3e0a00163672ab96aa0ca94572'

      getHash = (val) ->
        sha = new jsSHA val, 'TEXT'
        sha.getHash 'SHA-1', 'HEX'

      isAuthorized = (login, password) ->
        getHash(login) is credentials.login and
          getHash(password) is credentials.password

      @send = (e) ->
        e.preventDefault()
        login = document.getElementsByName('login')[0].value
        password = document.getElementsByName('password')[0].value
        if isAuthorized(login, password)
          golem.initRouting()
        else
          golem.notifications.helpers.error(
            body: 'Mot de passe ou identifiant invalides')
      return

    view: (ctrl) ->
      l = golem.config.locale
      [
        m 'section', { class: 'sixteen wide column' }, [
          m 'form', { class: 'ui form', onsubmit: ctrl.send }, [
            m 'div.field', [
              m 'label', l.LOGIN
              m 'div', { class: 'ui left labeled icon input' }, [
                m 'input',
                  name: 'login'
                  type: 'text'
                  placeholder: l.LOGIN
                m 'i', { class: 'icon asterisk' }
              ]
            ]
            m 'div.field', [
              m 'label', l.PASSWORD
              m 'div', { class: 'ui left labeled icon input' }, [
                m 'input',
                  name: 'password'
                  placeholder: l.PASSWORD
                  type: 'password'
                m 'i', { class: 'icon lock' }
              ]
            ]
            m 'input',
              class: 'ui blue submit button'
              type: 'submit'
              value: l.OK
          ]
        ]
      ]
