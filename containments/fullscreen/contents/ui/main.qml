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
import QtQuick.Controls 2.0 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import "LayoutManager.js" as LayoutManager

Item {
    id: root
    width: 480
    height: 640

//BEGIN properties
    property Item toolBox
    property var layoutManager: LayoutManager
    readonly property bool smallScreenMode: height < units.gridUnit * 20
//END properties

//BEGIN functions
    function addApplet(applet, x, y) {
        var container = appletContainerComponent.createObject(root, {"applet": applet})
        container.applet = applet;
        container.visible = true
        print("Applet added: " + applet)

        var appletWidth = applet.width;
        var appletHeight = applet.height;
        applet.parent = container;
        applet.anchors.fill = container;
        applet.visible = true;
        container.visible = true;

        // If the provided position is valid, use it.
        if (x >= 0 && y >= 0) {
            var index = LayoutManager.insertAtCoordinates(container, x , y);

        // Fall through to determining an appropriate insert position.
        } else {
            var before = null;
            //container.animationsEnabled = false;

            if (before) {
                LayoutManager.insertBefore(before, container);

            // Fall through to adding at the end.
            } else {
                container.parent = appletsSpace.layout;
            }

            //event compress the enable of animations
            //startupTimer.restart();
        }
    }





//END functions

//BEGIN slots
    Component.onCompleted: {
        LayoutManager.plasmoid = plasmoid;
        LayoutManager.root = root;
        LayoutManager.layout = appletsSpace.layout;
        LayoutManager.restore();
    }

    Containment.onAppletAdded: {
        addApplet(applet, x, y);
        LayoutManager.save();
    }

//END slots

    Component {
        id: appletContainerComponent
        MouseArea {
            id: appletContainer
            //not used yet
            property bool animationsEnabled: true
            property Item applet
            z: applet && applet.compactRepresentationItem && applet.expanded ? 99 : 0
            opacity: 1 - Math.abs(x/(width/2))
            Layout.fillWidth: true
            Layout.fillHeight: applet && applet.Layout.fillHeight

            Connections {
                target: plasmoid

                onAppletRemoved: {
                    print("Applet removed Applet-" + applet.id)
                    if (applet.id == appletContainer.applet.id) {
                        appletContainer.destroy();
                    }
                }
            }

            onAppletChanged: {
                if (applet.backgroundHints == PlasmaCore.Types.StandardBackground) {
                    applet.anchors.margins = background.margins.top;
                } 
            }

            property int oldX: x
            property int oldY: y
            PlasmaCore.FrameSvgItem {
                id: background
                z: -1
                anchors.fill: parent
                imagePath: "widgets/background"
                visible: applet.pluginName != "org.kde.plasma.mycroftplasmoid" && applet.backgroundHints == PlasmaCore.Types.StandardBackground
            }

            width: parent.width
            height: Math.max(applet.switchHeight + 1 + background.margins.top + background.margins.bottom, Math.max(applet.Layout.minimumHeight, root.height / 2))
            
            PlasmaComponents.BusyIndicator {
                z: 1000
                visible: applet && applet.busy
                running: visible
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
            }
        }
    }

    EditOverlay {
        id: editOverlay
        z: 999
    }

    MouseEventListener {
        id: mainListener
        anchors.fill: parent

        //Events handling: those events are about clicking and reordering of app icons
        //applet related events are in AppeltsArea.qml
        onPressAndHold: {
            var pos = mapToItem(appletsSpace.favoritesStrip, mouse.x, mouse.y);
            //in favorites area?
            var item;
            if (appletsSpace.favoritesStrip.contains(pos)) {
                item = appletsSpace.favoritesStrip.itemAt(pos.x, pos.y);
            }
        }

        onReleased: {
            appletsView.interactive = true;
            appletsView.dragData = null;
        }

        PlasmaCore.ColorScope {
            id: initialScreen
            anchors.fill: parent

            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

            Flickable {
                id: appletsArea
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: root.smallScreenMode ? parent.height : parent.height / 3
                contentHeight: height
                contentWidth: appletsSpace.width
                AppletsArea {
                    id: appletsSpace
                    height: parent.height
                }
            }

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                visible: !root.smallScreenMode
                height: (parent.height / 3) * 2
                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    text: "Some mycroft dashbard stuff, useful only for 3rd gen"
                }
            }
        }
        //FIXME: placeholder
        PlasmaComponents.Button {
            z:999
            anchors.bottom: parent.bottom
            text: "Hey Mycroft"
            onClicked: {
                if (mainStack.depth > 1) {
                    mainStack.pop();
                } else {
                    mainStack.push(mycroftView);
                }
            }
        }
        Item {
            id: mycroftView
        }
        Controls.StackView {
            id: mainStack
            anchors.fill: parent

            initialItem: initialScreen
        }
    }
}
