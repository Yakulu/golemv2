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
        var me = this;
        me.title = title;
        me.content = content;
        me.extra = extra;
        me.isPopupVisible = false;
        me.togglePopup = function () {
          me.isPopupVisible = !me.isPopupVisible;
        };
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
    selectHelper: function (config) {
      // TODO
      // Defaults
      // Attributes
      var selectAttr = {};
      // Element
      return m('select', selectAttr);
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
      if (config.oninput) { inputAttr.oninput = config.oninput; }
      if (config.validationMsg) {
        inputAttr.oninput = function (e) {
          var name = e.target.getAttribute('name');
          var isValid = e.target.checkValidity();
          var parent = e.target.parentNode;
          if (isValid) {
            parent.classList.remove('error');
            parent.lastChild.style.display = 'none';
          } else {
            parent.classList.add('error');
            parent.lastChild.style.display = 'block';
          }
          if (config.validationCallback) { config.validationCallback(e); }
        };
      }
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
      if (config.validationMsg) {
        var validationElement = m(
          'div',
          { class: 'ui red pointing above label', style: { display: 'none' } },
          config.validationMsg
        );
      } else {
        var validationElement = '';
      }
      return m('div', { class: cls }, [
        label,
        form.inputHelper(config),
        validationElement
      ]);
    },
    sortTableHeaderHelper: function (config) {
      var varName = config.field + 'IconDisplay';
      if (!config.ctrl[varName]) { config.ctrl[varName] = 'hidden'; }
      var attributes = {
        'data-sort-by': config.field,
        onmouseover: function () { config.ctrl[varName] = 'visible'; },
        onmouseout: function () { config.ctrl[varName] = 'hidden'; },
        onclick: config.ctrl.sort,
        style: { cursor: 'pointer' }
      };
      var title = config.title || config.field.toUpperCase();
      var content = [
        m('span', attributes, golem.utils.locale(title)),
        m('i', {
          class: 'icon sort',
          style: { visibility: config.ctrl[varName], marginLeft: '3px' }
        })
      ];
      return m('th', { 'data-sort-by': config.field }, content);
    },
    multiFieldWidget: {
      // TODO : non trivial, make fidel representation of fields in reactive elements for m.withAttr...
      controller: function (config) {
        var me = this;
        var l = golem.utils.locale;
        // Internal state
        me.tagName = config.tagName;
        me.type = config.type;
        me.label = config.label;
        me.name = config.name;
        me.size = config.size;
        me.maxlength = config.maxlength;
        me.minlength = config.minlength;
        me.content = config.content;
        // Defaults
        me.required = config.required || 'required';
        me.placeholder = config.placeholder || '';
        me.radioField = config.radioField || false;
        me.labelField = config.labelField || false;
        me.labels = config.labels || [];
        me.removeNum = m.prop();
        me.suffix = m.prop();
        me.value = '';
        // Reactive element
        me.current = config.current;
        // Methods
        me.setSuffix = function (num) {
          me.suffix = '-' + num;
        };
        me.setValue = function (obj) {
          if (obj.value !== undefined) {
            me.value = obj.value;
          } else {
            me.value = obj;
          }
        };
        me.addField = function () {
          var field;
          if (!me.labelField) {
            field = '';
          } else {
            field = { label: '', value: '' };
            if (me.radioField) { field.default = false; }
          }
          me.current.push(field);
        };
        me.change = function (num, field, e) {
          switch (field) {
            case 'default':
              for (var i = 0, l = me.current.length; i < l; i++) {
                me.current[i].default = (i === num);
              }
              break;
            case 'www':
              me.current[num] = e.target.value;
              break;
            default: // Label and classic value
              me.current[num][field] = e.target.value;
          }
        };
        // Children Modules
        me.helpButton = new form.helpButton.controller(
          me.label,
          me.content,
          form.addButton(me.addField, l('MENU_NEW'))
        );
        // Remove Modal
        var removeField = function () {
          me.current.splice(me.removeNum(), 1);
          me.removeModalCtrl.toggle();
        };
        me.removeModalCtrl = new widgets.modal.controller({
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
          var valueField = (ctrl.tagName && ctrl.tagName === 'select') ? form.selectHelper(ctrl) : form.inputHelper(ctrl);
          fields.push(m('div', { class: 'seven wide field' }, [
              m('div', { class: 'ui action input' }, [
                valueField,
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
        var me = this;
        // Initialization
        me.label = config.label;
        me.placeholder = config.placeholder;
        me.content = config.content;
        // Defaults
        me.size = config.size || 10;
        me.name = config.name || 'tags';
        // All tags except those already selected
        var tags = config.tags.filter(function (tag) {
          return (config.current.indexOf(tag) === -1);
        });
        // Reactive elements
        me.tags = tags;
        me.current = config.current;
        // Children modules
        me.helpButton = new form.helpButton.controller(me.label, me.content);
        // Methods
        me.add = function (input) {
          var v = input.value;
          if (v && me.current.indexOf(v) === -1) {
            me.current.push(v);
            //config.model[this.name].push(v); 
          }
          var vIdx = me.tags.indexOf(v);
          if (vIdx !== -1) {
            me.tags.splice(vIdx, 1);
          }
          input.value = '';
        };
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
