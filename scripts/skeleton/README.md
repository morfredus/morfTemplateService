# morfTemplateService

*Read in another language: **English** (this document) · [Français](README.fr.md).*

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](CHANGELOG.md)
![C++](https://img.shields.io/badge/C%2B%2B-17-00599C?logo=cplusplus)
![Qt](https://img.shields.io/badge/Qt-6-41CD52?logo=qt)
![Build](https://img.shields.io/badge/CMake-3.21+-064F8C?logo=cmake)
![License](https://img.shields.io/badge/License-GPL--3.0--only-blue)

**morfTemplateService is a morfSystem service.** TODO: describe its single responsibility in one
sentence.

## Build

Needs **Qt 6** (Core, Network). morfBeacon is vendored under `third_party/morf/beacon`.

```sh
cmake --preset mingw        # or linux / linux-arm64
cmake --build --preset mingw
ctest --test-dir build-mingw
```

## Run

```sh
./build-mingw/service/morftemplate.exe
curl http://127.0.0.1:8901/status
```

The HTTP port (8901) is provisional: reserve a real one in `ports.allocations` of
`morfTools/ecosystem.json`, then set it in `config/morftemplate.example.json` and in
`include/morftemplate/ServiceConfig.h`.

## Install as a service

```sh
sudo ./service.py install      # build if needed, install, start
sudo ./service.py update       # rebuild, replace the binary, restart
sudo ./service.py uninstall    # deregister, keeping the configuration
./service.py status
```

The service is declared in `service.json` (name, directories, configuration, purge categories).

## Documentation

French documentation in [`docs/fr/`](docs/fr/README.md).

## License

GPL-3.0-only - © @YEAR@ morfredus.
