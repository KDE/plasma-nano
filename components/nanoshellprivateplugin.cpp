/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: MIT
*/

#include "nanoshellprivateplugin.h"
#include "fullscreenoverlay.h"

#include <QtQml>


void PlasmaMiniShellPrivatePlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.plasma.private.nanoshell"));

    qmlRegisterType<FullScreenOverlay>(uri, 2, 0, "FullScreenOverlay");
}
