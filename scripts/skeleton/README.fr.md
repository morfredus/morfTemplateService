# morfTemplateService

*Lire dans une autre langue : [English](README.md) · **Français** (ce document).*

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](CHANGELOG.md)
![C++](https://img.shields.io/badge/C%2B%2B-17-00599C?logo=cplusplus)
![Qt](https://img.shields.io/badge/Qt-6-41CD52?logo=qt)
![Build](https://img.shields.io/badge/CMake-3.21+-064F8C?logo=cmake)
![License](https://img.shields.io/badge/License-GPL--3.0--only-blue)

**morfTemplateService est un service morfSystem.** TODO : décrire sa responsabilité unique en une
phrase.

## Compiler

Nécessite **Qt 6** (Core, Network). morfBeacon est vendoré dans `third_party/morf/beacon`.

```sh
cmake --preset mingw        # ou linux / linux-arm64
cmake --build --preset mingw
ctest --test-dir build-mingw
```

## Lancer

```sh
./build-mingw/service/morftemplate.exe
curl http://127.0.0.1:8901/status
```

Le port HTTP (8901) est provisoire : réserver un vrai port dans `ports.allocations` de
`morfTools/ecosystem.json`, puis le reporter dans `config/morftemplate.example.json` et dans
`include/morftemplate/ServiceConfig.h`.

## Installer en service

```sh
sudo ./service.py install      # compile si besoin, installe, démarre
sudo ./service.py update       # recompile, remplace le binaire, redémarre
sudo ./service.py uninstall    # désinscrit, en conservant la configuration
./service.py status
```

Le service est déclaré dans `service.json` (nom, dossiers, configuration, catégories de purge).

## Documentation

- [Architecture](docs/fr/ARCHITECTURE.md) - les classes et le fil d'exécution.
- [Emplacements des fichiers](docs/fr/FILESYSTEM.md) - config, état, programme.

## Licence

GPL-3.0-only - © @YEAR@ morfredus.
