# Journal des versions - morfTemplateService

Le format s'inspire de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/)
et du [versionnage sémantique](https://semver.org/lang/fr/).

## [0.5.0] - 2026-08-20

### Ajouté

- Mise à jour de la copie vendorée de morfDeploy 0.14.0 pour le packaging avec
  provenance vérifiée.

## [0.4.3] - 2026-08-14

### Corrigé

- **Troncature des grandes réponses HTTP** dans `HttpServer::reply()`. La méthode
  écrivait la réponse puis appelait `disconnectFromHost()` sans drainer le tampon
  d'écriture : toute réponse dépassant la taille du tampon socket (~20 Ko constaté)
  arrivait coupée côté client. Le correctif attend maintenant que `bytesToWrite()`
  retombe à zéro (via `waitForBytesWritten`, avec délai de garde) avant de fermer.
  Bug découvert dans morfAnalytics (page `/photo` > 30 Ko coupée en plein `<script>`)
  et corrigé ici dans le patron, source de vérité du squelette repris par tout le parc.
- Resynchronisation de la copie vendorée de **morfBeacon** (`third_party/morf/beacon`)
  en 0.6.1 : même classe de bug corrigée dans son `StatusServer` (grande réponse
  `/status` coupée faute de drainage du tampon d'écriture).

## [0.4.2] - 2026-08-14

### Corrigé

- Suppression des tirets cadratins dans les fichiers du template (commentaires,
  docstrings, CMake, chaîne runtime, en-tête `LICENSE`, unité systemd), au profit
  du tiret simple imposé par la constitution. Le patron ne propage donc plus
  cette ponctuation interdite aux services clonés.

## [0.4.1] - 2026-08-14

### Modifié

- Resynchronisation de la copie vendorée de **morfBeacon**
  (`third_party/morf/beacon`) en 0.6.0, alignée sur le dépôt source
  (`IMetricsProvider.h`, `StatusServer.cpp`). Aucun changement de comportement.
- Ajout du marqueur de version manquant à la copie vendorée de **morfdeploy**
  (`third_party/morf/morfdeploy/VERSION` = 0.1.0) ; le code Python était déjà à
  jour. `morf doctor` de nouveau vert sur les copies vendorées.

## [0.4.0] - 2026-07-28

### Ajouté

- **Doctrine config / état / programme, posée comme référence du parc.** Nouveau
  document `docs/fr/FILESYSTEM.md` : le programme vit sous `/opt`, la config admin
  (lecture seule) sous `/etc/morfsystem/<service>`, et **l'état persistant généré
  par le service** (clés, coffres, curseurs, séquences de sync, index) sous
  `/var/lib/morfsystem/<service>`.
- **Composant `Paths`** (`include/morftemplate/Paths.h`, `src/Paths.cpp`) :
  résolution de la racine d'état via `$STATE_DIRECTORY` (posé par systemd), avec
  repli `/var/lib/morfsystem/<service>` (Linux) ou `%ProgramData%\morfsystem\<service>\state`
  (Windows).
- **Superposition de configuration** : la config admin de `/etc` (lecture seule)
  est fusionnée au chargement avec un fichier de surcharges éditables à
  l'exécution (`<service>.overrides.json`) rangé dans l'état. Le service n'écrit
  jamais dans `/etc`.

### Modifié

- **Unité systemd** : ajout de `StateDirectory=morfsystem/morftemplate` (systemd
  crée le dossier d'état possédé par l'utilisateur du service). Le manifeste
  `service.json` déclare un bloc `state_dir` par plateforme.

## [0.3.0] - 2026-07-28

### Modifié

- **Configuration regroupée sous `/etc/morfsystem/<service>`.** Tout le parc
  partage désormais un point d'entrée UNIQUE dans `/etc` (`/etc/morfsystem/`),
  qui contient le fichier partagé `morfsystem.json` et un sous-dossier par
  service, au lieu d'un `/etc/<service>` par service à la racine de `/etc`. Sous
  Windows : `%ProgramData%\morfsystem\<service>`. Les données restent sous
  `/opt/<service>`. L'ancien `/etc/<service>` est adopté à l'installation
  (`migrate_from`).


## [0.2.2] - 2026-07-26
### Ajouté

- **Déclaration de l'API dans `/status`, comme modèle.** Le squelette montre
  désormais comment un service se rend « bavard » pour le parc : lister son API
  dans `fillAnnouncedDetail` (`include/morftemplate/SelfDescription.h`), puis la
  laisser sérialiser par `morfbeacon::describeService` dans `/status`. Sans
  interface web, seul le bloc `api` est émis ; le commentaire explique comment
  déclarer une `web_ui` le cas échéant. Tout nouveau service copie ce patron.

### Modifié

- **`new-service.sh` suggère un port concret.** Le script exécute
  `ecosystem-check.py … next-port` de morfTools et affiche le plus petit port
  libre du bloc service à réserver, au lieu de « choisir un port libre ». Lire le
  registre à l'œil pour trouver un trou est précisément ce qui met deux projets
  sur le même numéro. Le rappel mentionne aussi que `morf doctor` refuse tout
  port de la plage template en production.


## [0.2.1] - 2026-07-22
### Modifié

- **Installation, mise à jour et désinstallation par `./service.py`** - point
  d'entrée unique multiplateforme (morfdeploy), en remplacement des scripts
  `install-service.sh`/`.ps1`. Le binaire de ce service est inchangé ; seul son
  mode de déploiement évolue.
- **La configuration vit désormais dans `/etc/morftemplate`** (convention Linux),
  séparée du binaire dans `/opt/morftemplate`. Le déplacement est déclaré : la config
  existante est adoptée, jamais écrasée.
- **Enrichissement à la mise à jour** : une clé introduite par une nouvelle
  version est ajoutée avec sa valeur par défaut, sans jamais toucher vos réglages.

## [0.2.0] - 2026-07-21

### Corrigé

- **Le gabarit livrait le port 8799, déjà attribué à morfAnalytics.** Tout
  service créé par la procédure recommandée démarrait donc sur un port occupé -
  échec de *bind*, ou pire, réponses provenant du mauvais service. Le défaut
  était situé sur le chemin nominal : il ne frappait pas un usage marginal, mais
  la voie officielle d'extension de l'écosystème.

  Le port passe à **8901**, dans le bloc 8900-8999 réservé aux gabarits et aux
  exemples. Un port de cette plage ne peut pas être confondu avec une
  attribution du parc : un projet cloné qui n'a pas encore réservé le sien est
  visiblement inachevé, au lieu d'entrer silencieusement en conflit.

- **La correction porte sur toute la chaîne, pas seulement sur la
  configuration.** `ServiceConfig::httpPort` valait aussi 8799 : ce défaut
  *compilé* s'applique quand aucun fichier de configuration n'est trouvé, si
  bien qu'un service correctement configuré pouvait malgré tout retomber sur le
  port de morfAnalytics. Sont alignés : `config/morftemplate.example.json`,
  `include/morftemplate/ServiceConfig.h`, `examples/minimal/main.cpp`, les deux
  README et les deux scripts d'installation de service.

### Ajouté

- `scripts/new-service.(sh|ps1)` rappelle désormais, en fin d'exécution, que le
  projet généré hérite d'un port de gabarit et indique la marche à suivre :
  réserver un port dans `ports.allocations` de `morfTools/ecosystem.json`, le
  reporter aux **deux** emplacements, puis vérifier avec `morf doctor`. Le
  script renommait les fichiers sans jamais mentionner le port, ce qui laissait
  l'étape entièrement à la mémoire de l'utilisateur.

### Modifié

- Documentation d'amorçage mise à jour avec les noms canoniques des projets.

## [0.1.1] - 2026-07-19

### Modifié

- **Copie vendorée de morfBeacon resynchronisée en 0.2.0** (champ `capabilities`
  du heartbeat). Ajout purement additif et facultatif ; ce projet n'annonce
  aucune capacité et son comportement est strictement inchangé. La
  resynchronisation évite que la copie embarquée ne dérive de l'amont.


### Corrigé

- **La mise à jour ne livrait jamais les nouveaux paramètres de configuration.**
  `update-service.sh` ne recopiait que le binaire et laissait `morftemplate.json`
  intact, par souci de préserver les réglages locaux. Conséquence : un paramètre
  introduit après l'installation restait absent indéfiniment, et la fonction
  correspondante ne s'activait jamais **sans que rien ne le signale**. La mise à
  jour **complète** désormais la configuration (`scripts/linux/merge-config.py`) :
  les valeurs déjà en place ne sont jamais modifiées, les clés manquantes sont
  ajoutées puis listées, et une sauvegarde précède toute écriture. Option
  `--no-config` pour laisser la configuration strictement intacte.
- **La configuration absente n'était pas recréée.** Après une installation
  partielle ou une suppression du dossier, la mise à jour laissait le service
  démarrer sans configuration. Elle est désormais recopiée depuis l'exemple.
- **L'unité systemd n'était pas rafraîchie.** Une modification du fichier
  `.service` dans le dépôt ne parvenait jamais à `/etc/systemd/system` : le
  service continuait de tourner avec l'ancienne définition.

## [0.1.0] - 2026-07-16

### Ajouté

- **Squelette réutilisable de service morfSystem**, distillé de morfSensor et
  morfNotify : architecture identique, sans code métier.
- **Point d'extension `IModule`** + `ModuleFactory` + `ModuleRegistry` ; module
  de démonstration `ExampleModule` fonctionnel.
- **Serveur HTTP générique** (GET + POST avec corps) : `/status` (compatible
  morfBeacon), `/healthz`, `/modules`, `/modules/{id}`, `POST /example`.
- **Chargeur de configuration JSON** (`ServiceConfig`, liste `modules`).
- **Annonce LAN via morfBeacon** embarqué (vendoré dans `third_party/morf/beacon`).
- **Installation en service** : `scripts/linux/` (systemd) **et**
  `scripts/windows/install-service.ps1` (Planificateur de tâches, sans dépendance).
- **Scripts de clonage** `scripts/new-service.(sh|ps1)` : amorcent un nouveau
  projet en remplaçant tous les noms ; le résultat compile tel quel.
- Documentation FR (architecture, guide de création d'un service).
