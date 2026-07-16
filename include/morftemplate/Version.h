/*
 * morfTemplateService
 * Copyright (C) 2026 morfredus
 * SPDX-License-Identifier: GPL-3.0-only
 */

#pragma once
#include <QString>

namespace morftemplate {

// Version, injectee par CMake depuis le fichier VERSION.
#ifndef MORFTEMPLATE_VERSION
#  define MORFTEMPLATE_VERSION "dev"
#endif

inline QString version() { return QStringLiteral(MORFTEMPLATE_VERSION); }

// Version du protocole HTTP/JSON expose. >>> A ADAPTER si l'API change. <<<
inline constexpr const char* kProtocol = "morftemplate/1";

} // namespace morftemplate
