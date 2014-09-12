(function () {
  golem.home = {
    main: {
      controller: function () {
        document.title =  golem.model.title(golem.utils.locale('MENU_HOME'));
      },
      view: function (ctrl) {
        var notif = golem.utils.sendNotificationNG;
        return [
          m('section', { class: 'fourteen wide column' }, [
            m('p', m.trust([

    '<h2>Bienvenue</h2>',
    '<p>Bienvenue sur GOLEM, logiciel libre de Gestion et d\'Organisation dédié aux MJC. GOLEM est publié sous licence <a href="http://www.gnu.org/licenses/agpl-3.0.html">AGPL v3</a>.</p>',
    '<p>Le projet a démarré en juin 2011 à l\'initiative de la <a href="http://www.frmjc-bourgogne.org/spip.php?article2027">Fédération Régionale des MJC de Bourgogne - Champagne</a> et grâce à l\'aide du <a href="http://www.region-bourgogne.fr/">Conseil Régional de Bourgogne</a>.</p>',
    '<p><a href="http://www.yaltik.com">Yaltik</a>, activité de l\'entrepreneur-salarié Fabien Bourgeois, exerçant au sein de la coopérative <a href="http://www.cap-services.coop/">Cap Services</a>, a été chargée d\'une partie de la gestion de projet et du développement de la solution. Plusieurs centaines d\'heures ont été investies en rendez-vous, entretiens, compte-rendus, échanges avec des éditeurs de solutions existantes et en recherche et développement.</p>',

    '<h2>Version de développement</h2>',
    '<p>GOLEM est une application <a href="https://developer.mozilla.org/fr/docs/JavaScript">JavaScript</a> qui repose sur le serveur de base de données et d\'applications <a href="https://couchdb.apache.org/">CouchDb</a> maintenu par la <a href="http://apache.org/">Fondation Apache</a> ansi que sur la bibliothèque <a href="http://www.sencha.com/products/extjs/">ExtJS de Sencha</a>.</p>',
    '<p>Vous vous trouvez sur la version de développement de GOLEM. Cela signifie :</p>',
    '<ul>',
    '<li>Que l\'aspect graphique n\'est pas finalisé et pourra être <strong>largement modifié</strong>.</li>',
    '<li>Que cette version n\'est pas optimisée pour un usage en production : elle prend davantage de temps à être chargée et est moins performante du fait de bibliothèques partagées incluses en modes développement et déboguage.</li>',
    '<li>Que vous devez vous attendre à une base de données partielle et non représentative.</li>',
    '<li>Que tous les navigateurs n\'ont pas été extensivement testés.</li>',
    '<li>Qu\'il est possible que certains bogues soient temporairement présents.</li>',
    '</ul>',

    '<h2>Feuille de route</h2>',
    '<p>GOLEM va poursuivre son évolution durant le premier semestre 2014 et au-delà. Sont prévus :</p>',
    '<ul>',
    '<li>Une refactorisation de la base de code existante.</li>',
    '<li>Des améliorations concernant la navigation, l\'ergonomie.</li>',
    '<li>De nombreux ajouts fonctionnels sur les modules présents : contacts, adhérents, familles, activités, inscriptions, gestion des utilisateurs...</li>',
    '<li>Le module communication : envois de courriels et / ou de SMS.</li>',
    '<li>La gestion de documents et la possibilité de fournir des pièces jointes sur l\'ensemble des éléments.</li>',
    '<li>L\'impression et les exports tableur au format CSV.</li>',
    '<li>L\'import des adhérents.</li>',
    '<li>À plus long terme : vues agendas, gestion des salles, statistiques, comptabilité...</li>',
    '<li>Les bénéfices de la R&D : mise à jour automatique de l\'application si souhaité, synchronisation des données entre plusieurs points avec tolérance à la panne, support du hors-ligne, modifications notifiées en temps réel.</li>',
    '<li>Le support de l\'ensemble des navigateurs récents du marché, ainsi que des périphériques mobiles (tablettes, téléphones).</li>'
							].join('')
						)),
            m('ul', [
              m('li', { onclick: notif.bind(null, { title: 'basic', body: 'basic' }) }, 'basic'),
              m('li', { onclick: notif.bind(null, { title: 'icon', body: 'icon', icon: true }) }, 'icon'),
              m('li', { onclick: notif.bind(null, { title: 'warning', body: 'and icon', icon: true, cls: 'warning' }) }, 'warning-icon'),
              m('li', { onclick: notif.bind(null, { title: 'error', body: 'unlimited', cls: 'error', timeout: false }) }, 'error-unlimited'),
              m('li', { onclick: notif.bind(null, { title: 'timeoutdiff', body: 'diff',  timeout: 6 }) }, 'timeout-diff'),
            ]), 
          ]),
          /*m('section', { class: 'four wide column' }, [
            m('p', 'Menu contextuel')
          ])*/
        ];
      }
    },
  };
}).call(this);
