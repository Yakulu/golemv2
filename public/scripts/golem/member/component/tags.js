(function () {
  var member = golem.module.member;
  var widgets = golem.widgets.common;
  member.component.tags = {
    controller: function () {
      var me = this;
      var l = golem.config.locale;
      var mi = member.data.menuItems;
      golem.menus.secondary.items = [ mi.list, mi.add, mi.tags, mi.skills ];
      document.title = golem.utils.title(l.TAGS_MANAGEMENT);
      me.tags = [];
      m.startComputation();
      member.data.getTags(
        function (err, res) {
          if (!err) {
            me.tags = res.rows.map(function (tag) {
              return tag.key[1];
            });
          }
        m.endComputation();
        }
      );
      me._updateTag = function (input, removal) {
        m.startComputation();
        var oldVal = input.getAttribute('data-value');
        var newVal;
        if (removal) {
          newVal = false;
        } else {
          newVal = input.value;
          if (newVal.length === 0) {
            input.value = oldVal;
            return;
          }
        }
        golem.model.db.query('tags/count', {
          reduce: false,
          key: ['member', oldVal],
          include_docs: true
        }, function (err, res) {
          if (err) {
            golem.notifications.helpers.errorUnexpected({ body: err });
            m.endComputation();
          } else {
            var docs = [];
            res.rows.forEach(function (row) {
              var idx = row.doc.tags.indexOf(oldVal);
              if (newVal) {
                row.doc.tags[idx] = newVal;
              } else {
                row.doc.tags.splice(idx, 1);
              }
              docs.push(row.doc);
            });
            golem.model.db.bulkDocs(docs, function (err, res) {
              if (err) {
                golem.notifications.helpers.errorUnexpected({ body: err });
              } else {
                golem.notifications.helpers.success(
                  { body: l.SUCCESS_UPDATE },
                  function () {
                    if (!newVal) {
                      var tagsIdx = me.tags.indexOf(oldVal);
                      me.tags.splice(tagsIdx, 1); 
                      me.removeModalCtrl.toggle();
                    } else {
                      me.tags[me.tags.indexOf(oldVal)] = newVal;
                    }
                  }
                );
              }
              m.endComputation();
            });
          }
        });
      };
      me.updateTagFromClick = function (e) {
        var input = e.target.parentElement.parentElement.children[0].children[0];
        me._updateTag(input);
      };
      var input = null;
      me.removeModalCtrl = new widgets.modal.controller({
        title: l.SURE,
        content: l.TAGS_DELETE_CONFIRM_MSG,
        acceptFn: function () {
          me._updateTag(input, true);
        }
      });
      me.removeTag = function (e) {
        input = e.target.parentElement.parentElement.children[0].children[0];
        me.removeModalCtrl.toggle();
      };
    },
    view: function (ctrl) {
      var l = golem.config.locale;
      var mainContent = m('section', [
        m('h2', l.TAGS_MANAGEMENT),
          m('ul', { class: 'ui bulleted list' }, ctrl.tags.map(function (tag) {
            return m('li', { class: 'item golem-tag' }, [
              m('span', { class: 'ui small input' }, [
                m('input', {
                  size: 10,
                  value: tag,
                  'data-value': tag
                })
              ]),
              m('span', { class: 'ui buttons' }, [
                m('button', {
                  type:'button',
                  class: 'ui tiny blue button',
                  onclick: ctrl.updateTagFromClick
                }, l.RENAME),
                m('span.or'),
                m('button', {
                  type:'button',
                  class: 'ui tiny red button',
                  onclick: ctrl.removeTag
                }, l.DELETE)
              ])
            ]);
          }))
        ]);
       var contextMenuContent = m('div', { class: 'six wide column' }, [
          m('div', { class: 'ui purple inverted segment' }, [
            m('h3', [
              m('i', { class: 'info icon' }),
              m('span', l.HELP)
            ]),
            m('p', m.trust(l.TAGS_MANAGEMENT_HELP_MSG))
          ]),
          new widgets.modal.view(ctrl.removeModalCtrl)
        ]);
      return [
        m('section', { class: 'ten wide column' }, [
          new golem.menus.secondary.view(), mainContent
        ]),
        m('section', { class: 'six wide column' }, contextMenuContent)
      ];
    }
  };
}).call(this);
