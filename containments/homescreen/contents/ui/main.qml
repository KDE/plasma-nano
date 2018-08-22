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

import "LayoutManager.js" as LayoutManager

Item {
    id: root
    width: 480
    height: 640

//BEGIN properties
    property Item toolBox
    property var layoutManager: LayoutManager
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

        if (applet.pluginName == "org.kde.plasma.mycroft") {
            container.parent = mycroftParent;
            container.anchors.fill = mycroftParent;
            return;
        }
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

    //Autoscroll related functions
    function scrollUp() {
        autoScrollTimer.scrollDown = false;
        autoScrollTimer.running = true;
        scrollUpIndicator.opacity = 1;
        scrollDownIndicator.opacity = 0;
    }

    function scrollDown() {
        autoScrollTimer.scrollDown = true;
        autoScrollTimer.running = true;
        scrollUpIndicator.opacity = 0;
        scrollDownIndicator.opacity = 1;
    }

    function stopScroll() {
        autoScrollTimer.running = false;
        scrollUpIndicator.opacity = 0;
        scrollDownIndicator.opacity = 0;
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

    Timer {
        id: autoScrollTimer
        property bool scrollDown: true
        repeat: true
        interval: 1500
        onTriggered: {
            //reordering launcher icons
            if (root.reorderingApps) {
                scrollAnim.to = scrollDown ?
                //Scroll down
                    Math.min(appletsView.contentItem.height - appletsSpace.height - root.height, appletsView.contentY + root.height/2) :
                //Scroll up
                    Math.max(0, appletsView.contentY - root.height/2);

            //reordering applets
            } else {
                scrollAnim.to = scrollDown ?
                //Scroll down
                    Math.min(-root.height, appletsView.contentY + root.height/2) :
                //Scroll up
                    Math.max(-appletsSpace.height + root.height, appletsView.contentY - root.height/2);
            }
            scrollAnim.running = true;
        }
    }

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
                visible: applet.backgroundHints == PlasmaCore.Types.StandardBackground
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
            } /*else {
                pos = mapToItem(appletsView.contentItem, mouse.x, mouse.y);
                item = appletsView.itemAt(pos.x, pos.y)
            }
            if (!item) {
                return;
            }

            appletsView.dragData = new Object;
            appletsView.dragData.ApplicationNameRole = item.modelData.ApplicationNameRole;
            appletsView.dragData.ApplicationIconRole =  item.modelData.ApplicationIconRole;
            appletsView.dragData.ApplicationStorageIdRole = item.modelData.ApplicationStorageIdRole;
            appletsView.dragData.ApplicationEntryPathRole = item.modelData.ApplicationEntryPathRole;
            appletsView.dragData.ApplicationOriginalRowRole = item.modelData.ApplicationOriginalRowRole;
            
            dragDelegate.modelData = appletsView.dragData;
            appletsView.interactive = false;
            root.reorderingApps = true;
            dragDelegate.x = Math.floor(mouse.x / root.buttonHeight) * root.buttonHeight
            dragDelegate.y = Math.floor(mouse.y / root.buttonHeight) * root.buttonHeight
            dragDelegate.xTarget = mouse.x - dragDelegate.width/2;
            dragDelegate.yTarget = mouse.y - dragDelegate.width/2;
            dragDelegate.opacity = 1;*/
        }
        onPositionChanged: {
            var pos = mapToItem(appletsView.contentItem, mouse.x, mouse.y);

            //SCROLL UP
            if (appletsView.contentY > 0 && mouse.y < root.buttonHeight + root.height / 4) {
                root.scrollUp();
            //SCROLL DOWN
            } else if (!appletsView.atYEnd && mouse.y > 3 * (root.height / 4)) {
                root.scrollDown();
            //DON't SCROLL
            } else {
                root.stopScroll();
            }

        }
        onReleased: {
            appletsView.interactive = true;
            appletsView.dragData = null;
            root.stopScroll();
        }

        PlasmaCore.ColorScope {
            anchors.fill: parent
            //TODO: decide what color we want applets
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

            PlasmaCore.Svg {
                id: arrowsSvg
                imagePath: "widgets/arrows"
                colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
            }
            PlasmaCore.SvgItem {
                id: scrollUpIndicator
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 300
                }
                z: 2
                opacity: 0
                svg: arrowsSvg
                elementId: "up-arrow"
                width: units.iconSizes.large
                height: width
                Behavior on opacity {
                    OpacityAnimator {
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            PlasmaCore.SvgItem {
                id: scrollDownIndicator
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: units.gridUnit * 2
                }
                z: 2
                opacity: 0
                svg: arrowsSvg
                elementId: "down-arrow"
                width: units.iconSizes.large
                height: width
                Behavior on opacity {
                    OpacityAnimator {
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Item {
                id: mycroftParent
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width/2
            }
            Flickable {
                id: appletsView
                anchors {
                    left: mycroftParent.right
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    topMargin: plasmoid.availableScreenRect.y
                    bottomMargin: root.height - plasmoid.availableScreenRect.y - plasmoid.availableScreenRect.height
                }

                property var dragData
                contentWidth: width
                contentHeight: appletsSpace.height


                NumberAnimation {
                    id: scrollAnim
                    target: appletsView
                    properties: "contentY"
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }

                AppletsArea {
                    id: appletsSpace
                    width: appletsView.width
                }
            }

            PlasmaComponents.ScrollBar {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                interactive: false
                flickableItem: appletsView
            }
        }
    }
}
