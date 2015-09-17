l = golem.config.locale
golem.config.season = 2015
golem.header =
  controller: ->
    changeSeason: (s) ->
      golem.config.season = s
      m.route '/'
  view: (c) ->
    m 'h1',
    { class: 'ui inverted black block small header center aligned' },
    [
      m('span', "#{l.TITLE} : #{l.HEADER}"),
      do ->
        cls = 'ui tiny button left attached'
        cls+= ' green active' if golem.config.season is 2015
        m('button', { class: cls, onclick: -> c.changeSeason 2015 }, '2015')
      do ->
        cls = 'ui tiny button right attached'
        cls+= ' green active' if golem.config.season is 2014
        m('button', { class: cls, onclick: -> c.changeSeason 2014 }, '2014')
    ]
