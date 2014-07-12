(function () {
  var contact = golem.module.contact;
  var widgets = golem.widgets.common;
  contact.component.tags = {
    controller: function () {
      var l = golem.utils.locale;
      golem.controller.call(this);
      var cmi = contact.data.menuItems;
      this.secondaryMenu.replace([ cmi.list, cmi.add, cmi.tags ]);
      document.title = this.docTitle + l('TAGS_MANAGEMENT');
      this.tags = [];
      m.startComputation();
      contact.data.getTags((function (err, res) {
        this.tags = res.rows.map(function (tag) {
          return tag.key[1];
        });
        m.endComputation();
      }).bind(this));
      this._updateTag = (function (input, removal) {
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
          key: ['contact', oldVal],
          include_docs: true
        }, (function (err, res) {
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
          golem.model.db.bulkDocs(docs, (function (err, res) {
            golem.utils.sendNotification(
              l('SUCCESS'),
              { body: l('SUCCESS_UPDATE') },
              (function () {
                if (!newVal) {
                  var tagsIdx = this.tags.indexOf(oldVal);
                  this.tags.splice(tagsIdx, 1); 
                  this.removeModalCtrl.toggle();
                }
                m.endComputation();
              }).bind(this)
            );
          }).bind(this));
        }).bind(this));
      }).bind(this);
      this.updateTagFromClick = (function (e) {
        var input = e.target.parentElement.parentElement.children[0].children[0];
        this._updateTag(input);
      }).bind(this);
      var input = null;
      this.removeModalCtrl = new widgets.modal.controller({
        title: l('SURE'),
        content: l('TAGS_DELETE_CONFIRM_MSG'),
        acceptFn: (function () {
          this._updateTag(input, true);
        }).bind(this)
      });
      this.removeTag = (function (e) {
        input = e.target.parentElement.parentElement.children[0].children[0];
        this.removeModalCtrl.toggle();
      }).bind(this);
    },
    view: function (ctrl) {
      var l = golem.utils.locale;
      this.mainContent = m('section', [
        m('h2', l('TAGS_MANAGEMENT')),
        m('div', { class: 'ui grid' }, [
          m('div', { class: 'ten wide column'}, [
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
                  }, l('RENAME')),
                  m('span.or'),
                  m('button', {
                    type:'button',
                    class: 'ui tiny red button',
                    onclick: ctrl.removeTag
                  }, l('DELETE'))
                ])
              ]);
            }))
          ]),
          m('div', { class: 'six wide column' }, [
            m('div', { class: 'ui purple inverted segment' }, [
              m('h3', [
                m('i', { class: 'info icon' }),
                m('span', l('HELP'))
              ]),
              m('p', m.trust(l('TAGS_MANAGEMENT_HELP_MSG')))
            ])
          ])
        ]),
        new widgets.modal.view(ctrl.removeModalCtrl)
      ]);
      return golem.view.call(this, ctrl);
    }
  };
}).call(this);
