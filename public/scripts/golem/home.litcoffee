# Homepage

A very static version of home, full with HTML markup. It explains the history
of the project and things like that ! And first, changing the document-s title.

    init = -> document.title = golem.utils.title L 'HOME'
    $home = """
            <section class='fourteen wide column'>
              <h2>Bienvenue</h2>
              <p>Bienvenue sur GOLEM, logiciel libre de Gestion et d'Organisation dédié aux MJC. GOLEM est publié sous licence <a href='http://www.gnu.org/licenses/agpl-3.0.html'>AGPL v3</a>.</p>
              <p>Le projet a démarré en juin 2011 à l'initiative de la <a href='http://www.frmjc-bourgogne.org/spip.php?article2027'>Fédération Régionale des MJC de Bourgogne - Champagne</a> et grâce à l'aide du <a href='http://www.region-bourgogne.fr/'>Conseil Régional de Bourgogne</a>.</p>
              <p><a href='http://www.yaltik.com'>Yaltik</a>, activité de l'entrepreneur-salarié Fabien Bourgeois, exerçant au sein de la coopérative <a href='http://www.cap-services.coop/'>Cap Services</a>, a été chargée d'une partie de la gestion de projet et du développement de la solution. Plusieurs centaines d'heures ont été investies en rendez-vous, entretiens, compte-rendus, échanges avec des éditeurs de solutions existantes et en recherche et développement.</p>
              <h2>Version de développement</h2>
              <p>GOLEM est une application <a href='https://developer.mozilla.org/fr/docs/JavaScript'>JavaScript</a> qui repose sur la plateforme serveur <a href='http://nodejs.org/'>node.js</a>, le cadriciel de développement <a href='http://expressjs.com/'>express</a> et le moteur de base de données <a href='http://pouchdb.com/'>PouchDB</a>. Côté client, le développement a été réalisé principalement à l'aide de la bibliothèque <a href='http://lhorie.github.io/mithril/'>Mithril</a> et du thème graphique <a href='http://semantic-ui.com/'>Semantic UI</a>.</p>
              <p>Vous vous trouvez sur la version de développement de GOLEM, refondu autour des besoins de la MJC de Valentigney. Cela signifie :</p>
              <ul>
                <li>Que l'aspect graphique n'est pas finalisé et pourra être partiellement modifié.</li>
                <li>Que cette version n'est pas complètement optimisée pour un usage en production : elle prend davantage de temps à être chargée et est moins performante du fait de bibliothèques partagées incluses en modes développement et déboguage.</li>
                <li>Que vous devez vous attendre à une base de données partielle et non représentative.</li>
                <li>Que tous les navigateurs n'ont pas été extensivement testés.</li>
                <li>Qu'il est possible que certains bogues soient temporairement présents.</li>
              </ul>
              <h2>Feuille de route</h2>
              <p>GOLEM va poursuivre son évolution durant le second semestre 2014 et au-delà. Sont prévus :</p>
              <ul>
                <li>Un retour des modules aujourd'hui dissimulés : familles, contacts, paiements.</li>
                <li>Des améliorations concernant la navigation, l'ergonomie.</li>
                <li>De nombreux ajouts fonctionnels sur les modules présents : adhérents, activités, inscriptions, gestion des utilisateurs...</li>
                <li>Le module communication : envois de courriels et / ou de SMS.</li>
                <li>La gestion de documents et la possibilité de fournir des pièces jointes sur l'ensemble des éléments.</li>
                <li>L'impression et les exports tableur au format CSV.</li>
                <li>L'import des adhérents.</li>
                <li>À plus long terme : vues agendas, gestion des salles, statistiques, comptabilité...</li>
                <li>Les bénéfices de la R&D : mise à jour automatique de l'application si souhaité, synchronisation des données entre plusieurs points avec tolérance à la panne, support du hors-ligne, modifications notifiées en temps réel.</li>
                <li>Le support de l'ensemble des navigateurs récents du marché, ainsi que des périphériques mobiles (tablettes, téléphones).</li>
              </ul>
            </section>
            """


## Public API

    golem.$home = ->
      init()
      $home
