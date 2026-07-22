# Journal des versions — morfTemplateService

Le format s'inspire de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/)
et du [versionnage sémantique](https://semver.org/lang/fr/).

## [Non publié]

## [0.2.1] – 2026-07-22
### Modifié

- **Installation, mise à jour et désinstallation par `./service.py`** — point
  d'entrée unique multiplateforme (morfdeploy), en remplacement des scripts
  `install-service.sh`/`.ps1`. Le binaire de ce service est inchangé ; seul son
  mode de déploiement évolue.
- **La configuration vit désormais dans `/etc/morftemplate`** (convention Linux),
  séparée du binaire dans `/opt/morftemplate`. Le déplacement est déclaré : la config
  existante est adoptée, jamais écrasée.
- **Enrichissement à la mise à jour** : une clé introduite par une nouvelle
  version est ajoutée avec sa valeur par défaut, sans jamais toucher vos réglages.

## [0.2.0] – 2026-07-21

### Corrigé

- **Le gabarit livrait le port 8799, déjà attribué à morfAnalytics.** Tout
  service créé par la procédure recommandée démarrait donc sur un port occupé —
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

## [0.1.1] – 2026-07-19

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

## [0.1.0] — 2026-07-16

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
