/*
 *  Copyright 2015 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

MouseArea {
    id: appletsArea
    z: 999
    property alias layout: appletsLayout
    width: root.width
    height: Math.max(appletsView.height, mainLayout.Layout.minimumHeight)
    property Item draggingApplet
    property int startMouseX
    property int startMouseY
    property int oldMouseX
    property int oldMouseY

    drag.filterChildren: true
    EventGenerator {
        id: eventGenerator
    }

    SequentialAnimation {
        id: removeAnim
        property Item target
        property real to
        NumberAnimation {
            properties: "x"
            duration: units.longDuration
            easing.type: Easing.InOutQuad
            target: removeAnim.target
            to: removeAnim.to
        }
        ScriptAction {
            script: removeAnim.target.applet.action("remove").trigger();
        }
    }

    onPressed: {
        startMouseX = mouse.x;
        startMouseY = mouse.y;
    }
    onPressAndHold: {
        var absolutePos = mapToItem(appletsLayout, mouse.x, mouse.y);
        var absoluteStartPos = mapToItem(appletsLayout, startMouseX, startMouseY);

        if (Math.abs(absolutePos.x - absoluteStartPos.x) > units.gridUnit*2 ||
            Math.abs(absolutePos.y - absoluteStartPos.y) > units.gridUnit*2) {
            print("finger moved too much, press and hold canceled")
            return;
        }

        editOverlay.visible = true;
        var pos = mapToItem(appletsLayout, mouse.x, mouse.y);
        draggingApplet = appletsSpace.layout.childAt(absolutePos.x, absolutePos.y);
        editOverlay.applet = draggingApplet;

        oldMouseX = mouse.x;
        oldMouseY = mouse.y;

        eventGenerator.sendGrabEvent(draggingApplet, EventGenerator.UngrabMouse);
        eventGenerator.sendGrabEvent(appletsArea, EventGenerator.GrabMouse);
        eventGenerator.sendMouseEvent(appletsArea, EventGenerator.MouseButtonPress, mouse.x, mouse.y, Qt.LeftButton, Qt.LeftButton, 0)

        if (draggingApplet) {
            draggingApplet.animationsEnabled = false;
            dndSpacer.height = draggingApplet.height;
            root.layoutManager.insertBefore(draggingApplet, dndSpacer);
            draggingApplet.parent = appletsArea;

            pos = mapToItem(appletsArea, mouse.x, mouse.y);
            draggingApplet.y = pos.y - draggingApplet.height/2;

            appletsView.interactive = false;
        }
    }

    onPositionChanged: {
        if (!draggingApplet) {
            return;
        }

        appletsView.interactive = false;
        if (Math.abs(mouse.x - startMouseX) > units.gridUnit ||
            Math.abs(mouse.y - startMouseY) > units.gridUnit) {
            editOverlay.opacity = 0;
        }

        draggingApplet.x -= oldMouseX - mouse.x;
        draggingApplet.y -= oldMouseY - mouse.y;
        oldMouseX = mouse.x;
        oldMouseY = mouse.y;

        var pos = mapToItem(appletsLayout, mouse.x, mouse.y);
        var itemUnderMouse = appletsSpace.layout.childAt(pos.x, pos.y);

        if (itemUnderMouse && itemUnderMouse != dndSpacer) {
            dndSpacer.parent = colorScope;
            if (pos.y < itemUnderMouse.y + itemUnderMouse.height/2) {
                root.layoutManager.insertBefore(itemUnderMouse, dndSpacer);
            } else {
                root.layoutManager.insertAfter(itemUnderMouse, dndSpacer);
            }
        }

        pos = mapToItem(root, mouse.x, mouse.y);
        //SCROLL UP
        if (appletsView.contentY > -appletsArea.height + root.height && pos.y < root.height/4) {
            root.scrollUp();
        //SCROLL DOWN
        } else if (appletsView.contentY < 0 && pos.y > 3 * (root.height / 4)) {
            root.scrollDown();
        //DON't SCROLL
        } else {
            root.stopScroll();
        }
    }
    onReleased: {
        if (!draggingApplet) {
            return;
        }

        if (draggingApplet.x > -draggingApplet.width/3 && draggingApplet.x < draggingApplet.width/3) {
            draggingApplet.x = 0;
            root.layoutManager.insertBefore( dndSpacer, draggingApplet);
        } else {
            removeAnim.target = draggingApplet;
            removeAnim.to = (draggingApplet.x > 0) ? root.width : -root.width
            removeAnim.running = true;
        }
        appletsView.interactive = true;
        dndSpacer.parent = colorScope;
        draggingApplet = null;
    }

    RowLayout {
        id: mainLayout
        anchors {
            fill: parent
        }

        PlasmaCore.ColorScope {
            id: colorScope
            //TODO: decide what color we want applets
            colorGroup: PlasmaCore.Theme.NormalColorGroup
            Layout.fillWidth: true
            Layout.minimumHeight: appletsLayout.implicitHeight
            Layout.maximumHeight: appletsLayout.implicitHeight
            Row {
                id: appletsLayout
                width: parent.width
                move: Transition {
                    NumberAnimation {
                        properties: "x,y"
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            
            Item {
                id: dndSpacer
                width: parent.width
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.minimumHeight: appletsLayout.children.length < 2 ? mainLayout.height / 2 : 0
        }
    }
}
