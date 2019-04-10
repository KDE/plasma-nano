/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.kirigami 2.6 as Kirigami

import QtQuick.Window 2.1


import org.kde.plasma.private.shell 2.0

Controls.Drawer {
    id: root

    property Item containment
    readonly property bool horizontal: containment.width <= containment.height
    readonly property int delegateSize: units.gridUnit * 8

    property int topPanelHeight
    property int bottomPanelHeight
    property int leftPanelWidth
    property int rightPanelWidth

    visible: true

    width: horizontal ? Screen.width : implicitWidth + bottomPanelHeight
    height: horizontal ? implicitHeight + leftPanelWidth : Screen.height
    edge: horizontal ? Qt.BottomEdge : Qt.LeftEdge

    leftPadding: leftPanelWidth
    rightPadding: horizontal ? rightPanelWidth : units.largeSpacing
    topPadding: horizontal ? 0 : topPanelHeight
    bottomPadding: bottomPanelHeight


    contentItem: Item {
        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight
        clip: false

        Behavior on implicitWidth {
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Controls.RoundButton {
            z: 1
            anchors.bottom: parent.bottom
            x: root.horizontal ? parent.width - width : 0

            icon.name: "view-filter"
            checked: categoriesView.visible
            onClicked: categoriesView.visible = !categoriesView.visible
        }

        GridLayout {
            id: layout
            anchors.fill: parent
            rows: root.horizontal ? 2 : 1
            columns: root.horizontal ? 1 : 2
            
            Controls.ScrollView {
                id: categoriesView
                visible: false
                clip: false
                Layout.fillWidth: root.horizontal
                Layout.fillHeight: !root.horizontal
                Layout.column: 1
                Layout.row: root.horizontal ? 2 : 1
                implicitHeight: units.gridUnit * 2
                implicitWidth: units.gridUnit * 8
                
                ListView {
                    clip: false
                    model: widgetExplorer.filterModel
                    orientation: root.horizontal ? ListView.Horizontal : ListView.Vertical
                    delegate: Kirigami.BasicListItem {
                        height: model.separator ? 1 : implicitHeight
                        width: root.horizontal ? implicitWidth : parent.width
                        text: model.separator ? "" : model.display
                        separatorVisible: false
                        reserveSpaceForIcon: false
                        checked: widgetExplorer.widgetsModel.filterType == model.filterType && widgetExplorer.widgetsModel.filterQuery == model.filterData

                        onClicked: {
                            widgetExplorer.widgetsModel.filterQuery = model.filterData
                            widgetExplorer.widgetsModel.filterType = model.filterType
                        }
                    }
                }
            }

            Controls.ScrollView {
                id: view
                clip: false
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.row: 1
                Layout.column: root.horizontal ? 1 : 2
                implicitWidth: delegateSize
                implicitHeight: delegateSize + units.gridUnit*3

                ListView {
                    clip: false
                    header: Kirigami.Heading {
                        text: i18n("Widgets")
                        visible: !root.horizontal
                        width: visible ? implicitWidth : 0
                        height: visible ? implicitHeight : 0
                    }
                    orientation: root.horizontal ? ListView.Horizontal : ListView.Vertical
                    model: widgetExplorer.widgetsModel
                    delegate: AppletDelegate {}
                }
                //FIXME
                Component.onCompleted: contentItem.clip = false;
            }
        }
    }

    WidgetExplorer {
        id: widgetExplorer
        //view: desktop
        onShouldClose: root.close();
    }
}
