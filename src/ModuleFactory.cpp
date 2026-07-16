/*
 * morfTemplateService
 * Copyright (C) 2026 morfredus
 * SPDX-License-Identifier: GPL-3.0-only
 */

#include "morftemplate/ModuleFactory.h"
#include "morftemplate/IModule.h"
#include "morftemplate/ExampleModule.h"   // <-- remplacer/completer par vos modules

namespace morftemplate {
namespace ModuleFactory {

// -----------------------------------------------------------------------------
// POUR AJOUTER UN MODULE METIER :
//   1. ecrire la classe (heriter d'IModule) ;
//   2. ajouter une branche dans create() qui lit ses parametres (def.params) ;
//   3. ajouter son nom dans knownTypes().
// Aucune autre partie du code (registre, serveur HTTP, service) ne change.
// -----------------------------------------------------------------------------

IModule* create(const ModuleDef& def, QString* error, QObject* parent) {
    const QString type = def.type.toLower();

    if (type == QLatin1String("example")) {
        const int periodMs = def.params.value("period_ms").toInt(5000);
        return new ExampleModule(def.id, periodMs, parent);
    }

    // >>> AJOUTER VOS TYPES ICI <<<
    //   if (type == QLatin1String("moncapteur")) { ... return new MonCapteur(...); }

    if (error)
        *error = QStringLiteral("type de module inconnu : '%1'").arg(def.type);
    return nullptr;
}

QStringList knownTypes() {
    return { QStringLiteral("example") };            // >>> ajouter vos types <<<
}

} // namespace ModuleFactory
} // namespace morftemplate
