/*
 *   Copyright 2015 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtGraphicalEffects 1.12

pragma Singleton

Window {
    id: window

    function open(splashIcon, title, color, x, y, sourceIconSize) {
        iconParent.scale = sourceIconSize/iconParent.width;
        background.scale = 0;
        background.x = -window.width/2 + x
        background.y = -window.height/2 + y
        window.title = title;
        icon.source = splashIcon;
        background.color = color;
        background.state = "open";
    }

    property alias state: background.state
    property alias icon: icon.source
    width: Screen.width
    height: Screen.height
    color: "transparent"
    onVisibleChanged: {
        if (!visible) {
            background.state = "closed";
        }
    }
    onActiveChanged: {
        if (!active) {
            background.state = "closed";
        }
    }

    Timer {
        running: background.state == "open"
        interval: 15000
        onTriggered: background.state = "closed";
    }

    Item {
        id: iconParent
        z: 2
        anchors.centerIn: background
        width: units.iconSizes.enormous
        height: width
        PlasmaCore.IconItem {
            id: icon
            anchors.fill:parent
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        }
        DropShadow {
            anchors.fill: icon
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: icon
        }
    }
    Rectangle {
        id: background
        width: window.width
        height: window.height

        state: "closed"

        states: [
            State {
                name: "closed"
                PropertyChanges {
                    target: window
                    visible: false
                }
            },
            State {
                name: "open"

                PropertyChanges {
                    target: window
                    visible: true
                }
            }
        ]

        transitions: [
            Transition {
                from: "closed"
                SequentialAnimation {
                    ScriptAction {
                        script: { 
                            window.showMaximized();
                        }
                    }
                    ParallelAnimation {
                        ScaleAnimator {
                            target: background
                            from: background.scale
                            to: 1
                            duration: units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        ScaleAnimator {
                            target: iconParent
                            from: iconParent.scale
                            to: 1
                            duration: units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: background
                            property: "x"
                            to: 0
                            duration: units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: background
                            property: "y"
                            to: 0
                            duration: units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        ]
    }
}
