/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1
import Qt5Compat.GraphicalEffects

import org.kde.plasma.plasmoid 2.0
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.20 as Kirigami

KSvg.FrameSvgItem {
    id: root
    imagePath: "widgets/background"
    opacity: plasmoid.corona.editMode
    enabledBorders: KSvg.FrameSvgItem.TopBorder | KSvg.FrameSvgItem.LeftBorder | KSvg.FrameSvgItem.RightBorder
    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    transform: Translate {
        y: plasmoid.corona.editMode ? 0 : root.height
        Behavior on y {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
    anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
    }
    width: childrenRect.width + fixedMargins.left + fixedMargins.right
    height: childrenRect.height + fixedMargins.top + fixedMargins.bottom - Kirigami.Units.smallSpacing

    RowLayout {
        x: parent.fixedMargins.left
        y: parent.fixedMargins.top
        PlasmaComponents.Button {
            text: i18n("Add Widgets...")
            onClicked: {
                plasmoid.internalAction("add widgets").trigger();
                plasmoid.corona.editMode = false;
            }
        }
        PlasmaComponents.Button {
            text: i18n("Configure Wallpaper...")
            onClicked: {
                plasmoid.internalAction("configure").trigger();
                plasmoid.corona.editMode = false;
            }
        }
    }
}

