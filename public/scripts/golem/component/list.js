(function () {
  var l = golem.utils.locale;
  golem.component.list = {
    search: function (e, items) {
      var val = e.target.value;
      if (val === '') {
        return false;
      }
      if (val.length > 3) {
        return items.filter(function (item) {
          var json = JSON.stringify(item).toLowerCase();
          return (json.indexOf(val.toLowerCase()) !== -1);
        });
      }
    },
    searchBox: function (searchFn) {
      return {
        head: m('div', { class: 'header item' }, l('GLOBAL_SEARCH')),
        content: m('div', { class: 'item' }, [
          m('div', { class: 'ui small icon input' }, [
            m('input', {
              type: 'search',
              placeholder: l('TYPE_HERE'),
              title: l('SEARCH_ERROR_TOO_SHORT'),
              oninput: searchFn
            }),
            m('i', { class: 'unhide icon' })
          ])
        ])
      };
    }
  };
}).call(this);
