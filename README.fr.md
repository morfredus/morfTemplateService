# morfTemplateService

*Lire dans une autre langue : [English](README.md) · **Français** (ce document).*

[![Version](https://img.shields.io/badge/version-0.1.1-blue)](CHANGELOG.md)
![C++](https://img.shields.io/badge/C%2B%2B-17-00599C?logo=cplusplus)
![Qt](https://img.shields.io/badge/Qt-6-41CD52?logo=qt)
![Build](https://img.shields.io/badge/CMake-3.21+-064F8C?logo=cmake)
![License](https://img.shields.io/badge/License-GPL--3.0--only-blue)

**Squelette réutilisable pour les services de l'écosystème morfSystem.** On le
clone, on code le métier dans des modules, et on obtient — gratuitement — une API
HTTP, un chargeur de config JSON, une annonce LAN (morfBeacon), un service systemd
**et** un service Windows, le tout fonctionnel du premier coup.

Distillé de morfSensor et morfNotify : même architecture, sans code métier.

## Ce qu'on a d'emblée

- **Point d'extension `IModule`** — branchez votre métier en un ou plusieurs
  modules (capteur, notifieur, collecteur…). Un `ExampleModule` fonctionnel sert
  de point de départ.
- **API HTTP** (GET + POST) — `GET /status` (compatible morfBeacon), `/healthz`,
  `/modules`, `/modules/{id}`, et `POST /example` qui montre la lecture d'un corps.
- **Config** — fichier JSON avec une liste `modules` ; une fabrique les instancie.
- **Annonce LAN** — heartbeat morfBeacon (embarqué, aucune dépendance externe).
- **Installation service** — `scripts/linux/` (systemd) et `scripts/windows/`
  (Planificateur de tâches), copie binaire + config dans un dossier fixe.
- **Aide au clonage** — `scripts/new-service.sh` / `.ps1` amorce un projet renommé.

## Amorcer un nouveau service

```sh
scripts/new-service.sh morfwatch morfWatch     # Linux/macOS
# scripts\new-service.ps1 morfwatch morfWatch  # Windows
```

Crée `../morfWatch_travail` avec tous les noms remplacés (`morfTemplateService` →
`morfWatch`, `morftemplate` → `morfwatch`, `MORFTEMPLATE` → `MORFWATCH`). Il
compile tel quel. Ensuite :

1. Codez votre logique dans `src/ExampleModule.*` (renommez-le) — implémentez
   `IModule`.
2. Enregistrez vos types dans `src/ModuleFactory.cpp` + `knownTypes()`.
3. Adaptez les routes HTTP (`src/HttpServer.cpp`) et la liste de sources CMake.
4. Mettez à jour commentaires / config / docs.

## Compiler

Nécessite seulement **Qt 6** (Core, Network). morfBeacon est vendoré dans
`third_party/morf/beacon`.

```sh
cmake --preset mingw        # ou linux / linux-arm64
cmake --build --preset mingw
```

## Lancer

```sh
./build-mingw/service/morftemplate.exe          # module 'example' de repli
curl http://127.0.0.1:8799/modules
```

## Installer en service

```sh
# Linux (systemd)
sudo ./scripts/linux/install-service.sh
# Windows (Planificateur de tâches, PowerShell Administrateur)
powershell -ExecutionPolicy Bypass -File scripts\windows\install-service.ps1
```

## Documentation

- [Architecture](docs/fr/ARCHITECTURE.md) — les classes et le fil d'exécution.
- [Guide « créer votre service »](docs/fr/INTEGRATION.md) — pas à pas.

## Licence

GPL-3.0-only — © 2026 morfredus (Frédéric Biron).
