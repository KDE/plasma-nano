/*
 *   SPDX-FileCopyrightText: 2011 Sebastian Kügler <sebas@kde.org>
 *   SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *   SPDX-FileCopyrightText: 2015 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.2
import QtQuick.Window 2.2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasmoid 2.0


Item {
    id: main
    objectName: "org.kde.desktoptoolbox"

    z: 999
    anchors.fill: parent

    Rectangle {
        anchors {
            left: parent.left
            bottom: parent.bottom
            right: parent.right
        }

        height: configButtons.height + configButtons.anchors.bottomMargin

        opacity: plasmoid.containment.corona.editMode
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }

        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    DesktopConfigButtons {
        id: configButtons
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: main.height - (plasmoid.availableScreenRect.y + plasmoid.availableScreenRect.height)
        }
    }
}
