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
import QtGraphicalEffects 1.0

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
            opacity: 1 - Math.abs(y/(height/2))

            Connections {
                target: plasmoid

                onAppletRemoved: {
                    print("Applet removed Applet-" + applet.id)
                    if (applet.id == appletContainer.applet.id) {
                        appletContainer.destroy();
                    }
                }
            }

            //this will kill any mouse events to the applet
            //first version is not interactive
            MouseArea {
                anchors.fill: parent
                z: 9999
                onPressed: mouse.accepted = true
            }

            layer.enabled: applet && applet.backgroundHints == PlasmaCore.Types.StandardBackground
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 2
            }

            implicitWidth: root.smallScreenMode ? root.width :  Math.max(applet.switchWidth + 1, Math.max( applet.Layout.minimumWidth, root.width/4))
            implicitHeight: appletsSpace.height

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

/*for the first version any direct manipulation is disabled, reenable in the future
    EditOverlay {
        id: editOverlay
        z: 999
    }
*/
    PlasmaCore.ColorScope {
        id: initialScreen
        anchors.fill: parent

        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

        Flickable {
            id: appletsView
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: units.largeSpacing
            }
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
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
