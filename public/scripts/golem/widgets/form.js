(function () {
  // Form commons
  var widgets = golem.widgets.common;
  var form = golem.widgets.form = {
    addButton: function (clickAction, text) {
     return m('button', {
       class: 'ui right attached tiny button',
       type: 'button',
       onclick: clickAction,
       }, [ m('i', { class: 'add sign icon' }), text ]
     );
    },
    helpButton: {
      controller: function (title, content, extra) {
        this.title = title;
        this.content = content;
        this.extra = extra;
        this.isPopupVisible = false;
        this.togglePopup = (function () {
          this.isPopupVisible = !this.isPopupVisible;
        }).bind(this);
      },
      view: function (ctrl) {
        var l = golem.utils.locale;
        var box = [];
        var cls = 'ui tiny button';
        if (ctrl.extra) {
          cls += ' left attached';
          box.push(ctrl.extra);
        }
        box.unshift(
          m('button',
            {
              class: ctrl.isPopupVisible ? cls + ' black' : cls,
              type: 'button',
              'data-title': ctrl.title,
              'data-content': ctrl.content,
              onclick: ctrl.togglePopup
            },
            [ m('i', { class: 'help icon' }), l('HELP') ]
          )
        );
        var popup = m('div', {
            class: 'ui visible center right inverted popup helper'
          }, [
            m('div', { class: 'header' }, [
              m('i',
                {
                  role: 'button',
                  class: 'close icon',
                  onclick: ctrl.togglePopup
                }
              ),
              ctrl.title
            ]),
            m('p', { class: 'content' }, m.trust(ctrl.content))
          ]
        );
        if (ctrl.isPopupVisible) { box.unshift(popup); }
        return m('div', box);
      }
    },
    inputHelper: function (config) {
      // Defaults
      var placeholder = config.placeholder || config.label;
      var type = config.type || 'text';
      var name = config.name + (config.suffix || '');
      // Attributes
      var inputAttr = {
        id: name,
        name: name,
        type: type,
        placeholder: placeholder,
        value: config.value
      };
      if (config.maxlength) { inputAttr.maxlength = config.maxlength; }
      if (config.minlength) { inputAttr.minlength = config.minlength; }
      if (config.size) { inputAttr.size = config.size; }
      if (config.required) { inputAttr.required = 'required'; }
      if (config.pattern) { inputAttr.pattern = config.pattern; }
      if (config.onchange) { inputAttr.onchange = config.onchange; }
      // Element
      return m('input', inputAttr);
    },
    textHelper: function (config) {
			var cls = config.cls || 'field small input';
      var labelText;
      if (config.required) {
        labelText = '* ' + config.label;
      } else {
        labelText = config.label;
      }
      var label = m('label', { for: config.name }, labelText);
      return m('div', { class: cls }, [
        label,
        form.inputHelper(config)
      ]);
    },
    multiFieldWidget: {
      // TODO : non trivial, make fidel representation of fields in reactive elements for m.withAttr...
      controller: function (config) {
        var l = golem.utils.locale;
        // Internal state
        this.type = config.type;
        this.label = config.label;
        this.name = config.name;
        this.size = config.size;
        this.maxlength = config.maxlength;
        this.minlength = config.minlength;
        this.content = config.content;
        // Defaults
        this.required = config.required || 'required';
        this.placeholder = config.placeholder || '';
        this.radioField = config.radioField || false;
        this.labelField = config.labelField || false;
        this.labels = config.labels || [];
        this.removeNum = m.prop();
        this.suffix = m.prop();
        this.value = '';
        // Reactive element
        this.current = config.current;
        // Methods
        this.setSuffix = (function (num) {
          this.suffix = '-' + num;
        }).bind(this);
        this.setValue = (function (obj) {
          if (obj.value !== undefined) {
            this.value = obj.value;
          } else {
            this.value = obj;
          }
        }).bind(this);
        this.addField = (function () {
          var field;
          if (!this.labelField) {
            field = '';
          } else {
            field = { label: '', value: '' };
            if (this.radioField) { field.default = false; }
          }
          this.current.push(field);
        }).bind(this);
        this.change = function (num, field, e) {
          switch (field) {
            case 'default':
              for (var i = 0, l = this.current.length; i < l; i++) {
                this.current[i].default = (i === num);
              }
              break;
            case 'www':
              this.current[num] = e.target.value;
              break;
            default: // Label and classic value
              this.current[num][field] = e.target.value;
          }
        };
        // Children Modules
        this.helpButton = new form.helpButton.controller(
          this.label,
          this.content,
          form.addButton(this.addField, l('MENU_NEW'))
        );
        // Remove Modal
        var removeField = (function () {
          this.current.splice(this.removeNum(), 1);
          this.removeModalCtrl.toggle();
        }).bind(this);
        this.removeModalCtrl = new widgets.modal.controller({
          title: l('SURE'),
          content: l('REMOVE_FIELD_CONFIRM_MSG'),
          acceptFn: removeField
        });
      },
      view: function (ctrl) {
        var l = golem.utils.locale;
        // Buttons
        // Input and remove fields
        var inputRemoveFields = function (num) {
          ctrl.setSuffix(num);
          var fields = [];
          var sel = ctrl.current[num];
          // Radio field
          if (ctrl.radioField) {
            var checked;
            if (sel) {
              checked = sel.default;
            } else {
              checked = false;
            }
            var radioField = m('input',
              {
                class: 'ui radio checkbox',
                title: l('DEFAULT'),
                type: 'radio',
                name: ctrl.name + '-default',
                required: 'required',
                value: num,
                checked: checked,
                onchange: ctrl.change.bind(ctrl, num, 'default')
            });

            fields.push(m('div', { class: 'two wide inline field' }, [
              radioField,
              m('label',
                { class: 'small', for: ctrl.name },
                l('DEFAULT'))
            ]));
          }

          // Label field
          if (ctrl.labelField) {
            var fieldId = ctrl.name + '-label-' + num;
            var labelField = m('div', { class: 'seven wide field' }, [
              m('input', {
                type: 'text',
                list: fieldId,
                name: fieldId,
                placeholder: l('TYPE'),
                size: 15,
                value: sel ? sel.label : '',
                onchange: ctrl.change.bind(ctrl, num, 'label')
              }),
              m('datalist', { id: fieldId },
                ctrl.labels.map(function (label) {
                  return m('option', { value: label.key[1] });
                })
              )
            ]);
            fields.push(labelField);
          }

          // Remove button
          var removeField = m('div', {
            role: 'button',
            class: 'ui tiny red icon button',
            title: l('DELETE'),
            onclick: function () {
              ctrl.removeNum(num);
              ctrl.removeModalCtrl.toggle();
            }
          }, [ m('i', { class: 'remove sign icon' }) ]);
          // All fields
          ctrl.setValue(sel);


          if (!ctrl.labelField) {
            ctrl.onchange = ctrl.change.bind(ctrl, num, 'www');
          } else { // Complex fields like mail and tel
            ctrl.onchange = ctrl.change.bind(ctrl, num, 'value');
          }
          fields.push(m('div', { class: 'seven wide field' }, [
              m('div', { class: 'ui action input' }, [
                form.inputHelper(ctrl),
                removeField
              ])
            ])
          );
          return m('div', { class: 'multitext fields' }, fields);
        };

        var fieldset = m('fieldset', { class: 'ui segment' }, [
          m('legend', ctrl.label),
          new form.helpButton.view(ctrl.helpButton),
          m('div', ctrl.current.map(function (item, i) {
            return inputRemoveFields(i);
          })),
          new widgets.modal.view(ctrl.removeModalCtrl)
        ]);

        return m('div', { class: 'field' }, [ fieldset ]);
      }
    },
    tagWidget: {
      controller: function (config) {
        // Initialization
        this.label = config.label;
        this.placeholder = config.placeholder;
        this.content = config.content;
        // Defaults
        this.size = config.size || 10;
        this.name = config.name || 'tags';
        // All tags except those already selected
        var tags = config.tags.filter(function (tag) {
          return (config.current.indexOf(tag) === -1);
        });
        // Reactive elements
        this.tags = tags;
        this.current = config.current;
        // Children modules
        this.helpButton = new form.helpButton.controller(this.label, this.content);
        // Methods
        this.add = (function (input) {
          var v = input.value;
          if (v && this.current.indexOf(v) === -1) {
            this.current.push(v);
            //config.model[this.name].push(v); 
          }
          var vIdx = this.tags.indexOf(v);
          if (vIdx !== -1) {
            this.tags.splice(vIdx, 1);
          }
          input.value = '';
        }).bind(this);
      },
      view: function (ctrl) {
        var l = golem.utils.locale;
        return m('div', { class: 'field tagfield' }, [
          m('fieldset', { class: 'ui segment' }, [
            m('legend', ctrl.label),
            new form.helpButton.view(ctrl.helpButton),
            m('div', { class: 'ui action input multitext' }, [
              m('input', {
                id: ctrl.name + '-input',
                name: ctrl.name,
                type: 'text',
                list: ctrl.name,
                placeholder: ctrl.placeholder,
                size: ctrl.size,
                onkeydown: function (e) {
                  if (e.keyCode === 13) { // Enter
                    e.preventDefault();
                    ctrl.add(e.target);
                  }
                },
                onchange: function (e) { ctrl.add(e.target); }
              }),
              m('div', {
                role: 'button',
                class: 'ui mini purple button',
                onclick: function (e) {
                  var ipt = document.getElementById(ctrl.name + '-input');
                  ctrl.add(ipt);
                }
              }, l('OK'))
            ]),
            m('datalist', { id: ctrl.name }, ctrl.tags.map(function (tag) {
              return m('option', { value: tag });
            })),
            m('p', ctrl.current.map(function (tag) {
              return m('div', { class: 'ui label purple golem-tag' }, [
                tag,
                m('i', {
                  role: 'button',
                  class: 'delete icon',
                  onclick: function (e) {
                    var value = e.target.parentElement.textContent;
                    var idx = ctrl.current.indexOf(value);
                    ctrl.current.splice(idx, 1);
                    ctrl.tags.push(value);
                    //$target.empty()
                  }
                })
              ]);
            }))
          ])
        ]);
      }
    }
  };
}).call(this);
