/*
 *  SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: root

    visible: false //adjust borders is run during setup. We want to avoid painting till completed
    property Item containment

    color: containment && containment.plasmoid.backgroundHints == PlasmaCore.Types.NoBackground ? "transparent" : Kirigami.Theme.textColor

    onContainmentChanged: {
        containment.parent = root;
        containment.visible = true;
        containment.anchors.fill = root;
        panel.backgroundHints = containment.backgroundHints;
    }

    Component.onCompleted: {
        visible = true
    }
}
