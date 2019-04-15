/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.12
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

PlasmaCore.FrameSvgItem {
    id: root
    imagePath: "widgets/background"
    opacity: plasmoid.editMode
    enabledBorders: PlasmaCore.FrameSvgItem.TopBorder | PlasmaCore.FrameSvgItem.LeftBorder | PlasmaCore.FrameSvgItem.RightBorder
    Behavior on opacity {
        OpacityAnimator {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    transform: Translate {
        y: plasmoid.editMode ? 0 : root.height
        Behavior on y {
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
    anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
    }
    width: childrenRect.width + fixedMargins.left + fixedMargins.right
    height: childrenRect.height + fixedMargins.top + fixedMargins.bottom - units.smallSpacing

    RowLayout {
        x: parent.fixedMargins.left
        y: parent.fixedMargins.top
        PlasmaComponents.Button {
            text: i18n("Add Widgets...")
            onClicked: {
                plasmoid.action("add widgets").trigger();
                plasmoid.editMode = false;
            }
        }
        PlasmaComponents.Button {
            text: i18n("Configure Wallpaper...")
            onClicked: {
                plasmoid.action("configure").trigger();
                plasmoid.editMode = false;
            }
        }
    }
}

