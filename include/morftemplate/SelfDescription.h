/*
 * morfTemplateService
 * Copyright (C) 2026 morfredus
 * SPDX-License-Identifier: GPL-3.0-only
 */

#pragma once
#include "morfbeacon/PresenceConfig.h"

namespace morftemplate {

// -----------------------------------------------------------------------------
// fillAnnouncedDetail : renseigne le DETAIL annonce du service dans un
// PresenceConfig, pour que morfbeacon::describeService le serialise dans /status.
//
// >>> MODELE. Ce squelette montre a un nouveau service COMMENT se decrire pour
// >>> le parc. Un service morfSystem se rend « bavard » d'une seule facon :
// >>>   1. lister ici son API (methode, chemin, resume) ;
// >>>   2. si -- et seulement si -- il expose une interface web, renseigner
// >>>      pc.webUiPath / pc.webUiLabel / pc.webUiDescription (voir morfAnalytics
// >>>      et morfMonitor). Sans interface, ne rien mettre : describeService
// >>>      n'emettra alors que le bloc `api`, sans cle `web_ui` fantome.
// >>>   3. appeler describeService dans HttpServer::buildStatusJson (fait plus bas).
//
// Point UNIQUE : le detail annonce est defini une seule fois, ici. Le heartbeat
// morfBeacon, lui, reste maigre -- il annonce des CAPACITES, pas l'API -- donc
// Service.cpp n'appelle pas cette fonction : le detail ne vit que dans /status.
//
// En-tete (inline) : aucun fichier source ni entree CMake supplementaires.
inline void fillAnnouncedDetail(morfbeacon::PresenceConfig& pc) {
    // >>> EXEMPLE d'API. A remplacer par les routes reelles du service.
    // Les routes de cadre -- /status, /healthz -- ne sont pas listees : un
    // observateur les connait deja par le protocole.
    pc.api = {
        {QStringLiteral("POST"), QStringLiteral("/example"),
         QStringLiteral("exemple de route metier -- a remplacer")},
        {QStringLiteral("GET"),  QStringLiteral("/modules"),
         QStringLiteral("liste des modules charges")},
        {QStringLiteral("GET"),  QStringLiteral("/modules/{id}"),
         QStringLiteral("detail d'un module designe par son identifiant")},
    };
}

} // namespace morftemplate
