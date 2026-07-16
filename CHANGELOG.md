# Journal des versions — morfTemplateService

Le format s'inspire de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/)
et du [versionnage sémantique](https://semver.org/lang/fr/).

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
