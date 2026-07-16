cmake_minimum_required(VERSION 3.21)

# =============================================================================
#  morfTemplateService — squelette reutilisable de service morfSystem.
#
#  POUR CREER UN NOUVEAU SERVICE : le plus simple est le script de clonage
#      scripts/new-service.sh   morfmonservice MorfMonService   (Linux/macOS)
#      scripts/new-service.ps1  morfmonservice MorfMonService   (Windows)
#  qui copie ce projet en remplacant les noms. Sinon, remplacer a la main :
#      morfTemplateService  (nom du projet / bibliotheque)
#      morftemplate         (namespace, dossier include, binaire, unite systemd)
#      MORFTEMPLATE         (prefixe de macro)
#
#  Ensuite : coder le metier dans src/ExampleModule.* (ou de nouveaux modules),
#  adapter la fabrique (src/ModuleFactory.cpp) et la liste de sources ci-dessous.
# =============================================================================

# Version pilotee par le fichier VERSION (convention morfSystem).
set(MORFTEMPLATE_VERSION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/VERSION")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${MORFTEMPLATE_VERSION_FILE}")
file(STRINGS "${MORFTEMPLATE_VERSION_FILE}" MORFTEMPLATE_VERSION_FROM_FILE LIMIT_COUNT 1)
string(STRIP "${MORFTEMPLATE_VERSION_FROM_FILE}" MORFTEMPLATE_VERSION_FROM_FILE)

project(morfTemplateService VERSION "${MORFTEMPLATE_VERSION_FROM_FILE}" LANGUAGES CXX)

# --- Standard C++ ---------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Qt : generation automatique du moc (classes QObject) -----------------
set(CMAKE_AUTOMOC ON)

# Core + Network : serveur HTTP entrant, client HTTP sortant, JSON. Ajouter
# ici les modules Qt dont le METIER a besoin (SerialPort, Sql, ...).
find_package(Qt6 REQUIRED COMPONENTS Core Network)

# --- Dependance morfBeacon (annonce de presence sur le LAN) ---------------
# morfBeacon est EMBARQUE (copie vendoree) dans third_party/morf/beacon, lie
# statiquement : le projet se compile sans dependre d'aucun depot externe, a
# l'identique sous Windows, Linux x64 et Raspberry Pi (ARM64).
# Ne pas editer third_party/ ; resynchroniser avec scripts/sync-morf.(sh|ps1).
if(NOT TARGET morfBeacon::morfBeacon)
    add_subdirectory(third_party/morf/beacon)
endif()

# --- Bibliotheque ---------------------------------------------------------
# >>> A ADAPTER : ajouter/retirer ici les sources de VOS modules metier. <<<
add_library(morfTemplateService STATIC
    src/ModuleRegistry.cpp
    src/HttpServer.cpp
    src/Service.cpp
    src/ModuleFactory.cpp
    src/ExampleModule.cpp                 # <-- remplacer par votre metier
    include/morftemplate/IModule.h
    include/morftemplate/ModuleRegistry.h
    include/morftemplate/ServiceConfig.h
    include/morftemplate/ModuleFactory.h
    include/morftemplate/HttpServer.h
    include/morftemplate/Service.h
    include/morftemplate/ExampleModule.h  # <-- remplacer par votre metier
    include/morftemplate/Version.h
)
add_library(morfTemplateService::morfTemplateService ALIAS morfTemplateService)

target_include_directories(morfTemplateService PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

target_link_libraries(morfTemplateService
    PUBLIC  Qt6::Core Qt6::Network
    PRIVATE morfBeacon::morfBeacon)

# Numero de version accessible depuis le code.
target_compile_definitions(morfTemplateService PUBLIC MORFTEMPLATE_VERSION="${PROJECT_VERSION}")

if(MSVC)
    target_compile_options(morfTemplateService PRIVATE /utf-8)
endif()

# --- Cible service (le demon autonome) ------------------------------------
add_subdirectory(service)

# --- Exemple (compile seulement en build autonome, pas via add_subdirectory) -
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(_morftemplate_standalone ON)
else()
    set(_morftemplate_standalone OFF)
endif()
option(MORFTEMPLATE_BUILD_EXAMPLES "Compiler l'exemple de demonstration" ${_morftemplate_standalone})

if(MORFTEMPLATE_BUILD_EXAMPLES)
    add_subdirectory(examples/minimal)
endif()
