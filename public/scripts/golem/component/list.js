(function () {
  var l = golem.utils.locale;
  golem.component.list = {
    search: function (e, items) {
      var val = e.target.value;
      if (val === '') {
        return false;
      }
      if (val.length > 2) {
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
    },
    tagsBox: function (tags, ctrl) {
			var tagsIconAttrs = { class: 'tags icon' };
			var tagsClass = '';
			if (ctrl.tagFilter) {
				tagsIconAttrs = { class: 'eraser icon', title: l('FILTERS_REMOVE') };
				tagsClass = ' active';
			}
			return {
				head: m('div', { class: 'header item' }, l('FILTERS')),
				groups: m('a', { class: 'item' }, [
					m('i', { class: 'users icon' }),
					l('BY_GROUPS')
				]),
				tags: m('div', [
					m('a', {
						class: 'item' + tagsClass,
						onclick: ctrl.unsetTagFilter
						//config: m.route
					}, [
						m('i', tagsIconAttrs),
						l('BY_TAGS')
					]),
					m('a', tags.map(function (tag) {
						var items = [
							tag.key[1],
							m('div', { class: 'ui small teal label' }, tag.value)
						];
						var classTag = 'item';
						if (ctrl.tagFilter === tag.key[1]) { classTag += ' active'; }
						return m('a', {
								class: classTag,
								onclick: ctrl.setTagFilter.bind(ctrl, tag.key[1])
							}, items);
					})
					)
				])
			};
		}
  };
}).call(this);
