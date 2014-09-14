l = golem.config.locale
golem.header =
  controller: ->
  view: ->
    m 'h1', { class: 'ui inverted black block small header center aligned' }, "#{l.TITLE} : #{l.HEADER}"
