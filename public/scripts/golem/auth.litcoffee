# Authentification

ATM it's just a fake, specifically created for the MJC of Valentigney...
So I won't comment it much.

    $auth = ->
      document.title = golem.utils.title L('AUTHENTIFICATION')
      credentials =
        login: '8d143618d8af1efbade9dba8b6c93434d98d3da1'
        password: 'db55970eeb626c3e0a00163672ab96aa0ca94572'

      getHash = (val) ->
        sha = new jsSHA val, 'TEXT'
        sha.getHash 'SHA-1', 'HEX'

      isAuthorized = (login, password) ->
        getHash(login) is credentials.login and
          getHash(password) is credentials.password

      send = (e) ->
        e.preventDefault()
        login = $('[name=login]').val()
        password = $('[name=password]').val()
        if isAuthorized login, password
          golem.initRouting()
        else
          new golem.widgets.common.notification.Error
            content: 'Mot de passe ou identifiant invalides'
          .send()

      [
        section { class: 'sixteen wide column' }, [
          form { class: 'ui form', submit: send }, [
            div { class: 'field' }, [
              label L('LOGIN')
              div { class: 'ui left labeled icon input' }, [
                input
                  name: 'login'
                  type: 'text'
                  placeholder: L 'LOGIN'
                i { class: 'icon asterisk' }
              ]
            ]
            div { class: 'field' }, [
              label L('PASSWORD')
              div { class: 'ui left labeled icon input' }, [
                input
                  name: 'password'
                  placeholder: L 'PASSWORD'
                  type: 'password'
                i { class: 'icon lock' }
              ]
            ]
            input
              class: 'ui blue submit button'
              type: 'submit'
              value: L 'OK'
          ]
        ]
      ]

## Public API

    golem.$auth = $auth
