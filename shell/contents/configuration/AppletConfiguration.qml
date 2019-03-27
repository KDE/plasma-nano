/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
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

import QtQuick 2.6
import QtQuick.Controls 2.3 as QtControls
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2

import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.configuration 2.0


//TODO: all of this will be done with desktop components
Item {
    id: root
    Layout.minimumWidth:  Screen.width
    Layout.minimumHeight: Screen.height
    

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

//BEGIN properties
    readonly property bool horizontal: root.width > root.height
    property bool isContainment: false
//END properties

//BEGIN model
    property ConfigModel globalConfigModel:  globalAppletConfigModel

    ConfigModel {
        id: globalAppletConfigModel
    }

    PlasmaCore.SortFilterModel {
        id: configDialogFilterModel
        sourceModel: configDialog.configModel
        filterRole: "visible"
        filterCallback: function(source_row, value) { return value; }
    }
//END model

//BEGIN functions
    function saveConfig() {
        if (pageStack.currentItem.saveConfig) {
            pageStack.currentItem.saveConfig()
        }
        for (var key in plasmoid.configuration) {
            if (pageStack.currentItem["cfg_"+key] !== undefined) {
                plasmoid.configuration[key] = pageStack.currentItem["cfg_"+key]
            }
        }
    }

    function configurationHasChanged() {
        for (var key in plasmoid.configuration) {
            if (pageStack.currentItem["cfg_"+key] !== undefined) {
                //for objects == doesn't work
                if (typeof plasmoid.configuration[key] == 'object') {
                    for (var i in plasmoid.configuration[key]) {
                        if (plasmoid.configuration[key][i] != pageStack.currentItem["cfg_"+key][i]) {
                            return true;
                        }
                    }
                    return false;
                } else if (pageStack.currentItem["cfg_"+key] != plasmoid.configuration[key]) {
                    return true;
                }
            }
        }
        return false;
    }


    function settingValueChanged() {
        if (pageStack.currentItem.saveConfig !== undefined) {
            pageStack.currentItem.saveConfig();
        } else {
            root.saveConfig();
        }
    }
//END functions


//BEGIN connections
    Component.onCompleted: {
        if (!isContainment && configDialog.configModel && configDialog.configModel.count > 0) {
            if (configDialog.configModel.get(0).source) {
                pageStack.sourceFile = configDialog.configModel.get(0).source
            } else if (configDialog.configModel.get(0).kcm) {
                pageStack.sourceFile = Qt.resolvedUrl("ConfigurationKcmPage.qml");
                pageStack.currentItem.kcm = configDialog.configModel.get(0).kcm;
            } else {
                pageStack.sourceFile = "";
            }
            pageStack.title = configDialog.configModel.get(0).name
        } else {
            pageStack.sourceFile = globalConfigModel.get(0).source
            pageStack.title = globalConfigModel.get(0).name
        }
//         root.width = dialogRootItem.implicitWidth
//         root.height = dialogRootItem.implicitHeight
    }
//END connections

//BEGIN UI components

    QtControls.Dialog {
        id: dialog
        visible: true
        onClosed: configDialog.close()
        x: parent.width/2 - width/2
        y: parent.height - height
        width: Math.min(dialogRootItem.implicitWidth + leftPadding + rightPadding, root.width)
        height: Math.min(root.height - units.gridUnit * 2, dialogRootItem.implicitHeight + topPadding + bottomPadding, root.height)

        Item {
            id: dialogRootItem
            anchors.fill: parent

            states: [
                State {
                    name: "horizontal"
                    when: root.horizontal
                    PropertyChanges {
                        target: dialogRootItem
                        implicitWidth: categoriesScroll.width + units.smallSpacing + scroll.implicitWidth 
                        implicitHeight: scroll.implicitHeight
                    }
                    AnchorChanges {
                        target: categoriesScroll
                        anchors.left: dialogRootItem.left
                        anchors.top: dialogRootItem.top
                        anchors.bottom: dialogRootItem.bottom
                    }
                    AnchorChanges {
                        target: scroll
                        anchors.left: categoriesScroll.right
                        anchors.right: dialogRootItem.right
                        anchors.top: dialogRootItem.top
                        anchors.bottom: dialogRootItem.bottom
                    }
                    PropertyChanges {
                        target: scroll
                        anchors.leftMargin: units.smallSpacing
                        anchors.bottomMargin: 0
                    }
                    PropertyChanges {
                        target: categoriesScroll
                        width: Math.min(categories.implicitWidth, units.gridUnit * 7)
                    }
                    AnchorChanges {
                        target: separator
                        anchors.left: categoriesScroll.right
                        anchors.right: undefined
                        anchors.top: dialogRootItem.top
                        anchors.bottom: dialogRootItem.bottom
                    }
                    PropertyChanges {
                        target: separator
                        width: Math.round(units.devicePixelRatio)
                    }
                },
                State {
                    name: "vertical"
                    when: !root.horizontal
                    PropertyChanges {
                        target: dialogRootItem
                        implicitWidth: scroll.implicitWidth
                        implicitHeight: categoriesScroll.height + units.smallSpacing + scroll.implicitHeight
                    }
                    AnchorChanges {
                        target: categoriesScroll
                        anchors.left: dialogRootItem.left
                        anchors.right: dialogRootItem.right
                        anchors.top: undefined
                        anchors.bottom: dialogRootItem.bottom
                    }
                    AnchorChanges {
                        target: scroll
                        anchors.left: dialogRootItem.left
                        anchors.right: dialogRootItem.right
                        anchors.top: dialogRootItem.top
                        anchors.bottom: categoriesScroll.top
                    }
                    PropertyChanges {
                        target: scroll
                        anchors.leftMargin: 0
                        anchors.bottomMargin: units.smallSpacing
                    }
                    PropertyChanges {
                        target: categoriesScroll
                        height: categories.implicitHeight
                    }
                    AnchorChanges {
                        target: separator
                        anchors.left: dialogRootItem.left
                        anchors.right: dialogRootItem.right
                        anchors.top: undefined
                        anchors.bottom: categoriesScroll.top
                    }
                    PropertyChanges {
                        target: separator
                        height: Math.round(units.devicePixelRatio)
                    }
                }
            ]

            QtControls.ScrollView {
                id: categoriesScroll

                visible: (configDialog.configModel ? configDialog.configModel.count : 0) + globalConfigModel.count > 1

                Keys.onUpPressed: {
                    var buttons = categories.children

                    var foundPrevious = false
                    for (var i = buttons.length - 1; i >= 0; --i) {
                        var button = buttons[i];
                        if (!button.hasOwnProperty("current")) {
                            // not a ConfigCategoryDelegate
                            continue;
                        }

                        if (foundPrevious) {
                            button.openCategory()
                            return
                        } else if (button.current) {
                            foundPrevious = true
                        }
                    }
                }

                Keys.onDownPressed: {
                    var buttons = categories.children

                    var foundNext = false
                    for (var i = 0, length = buttons.length; i < length; ++i) {
                        var button = buttons[i];
                        console.log(button)
                        if (!button.hasOwnProperty("current")) {
                            continue;
                        }

                        if (foundNext) {
                            button.openCategory()
                            return
                        } else if (button.current) {
                            foundNext = true
                        }
                    }
                }

                GridLayout {
                    id: categories
                    rowSpacing: 0
                    columnSpacing: 0
                    rows: root.horizontal ? -1 : 1
                    columns: root.horizontal ? 1 : -1
                    width: root.horizontal ? categoriesScroll.width : implicitWidth
                    height: root.horizontal ? implicitHeight : categoriesScroll.height

                    property Item currentItem: children[1]

                    Repeater {
                        model: root.isContainment ? globalConfigModel : undefined
                        delegate: ConfigCategoryDelegate {}
                    }
                    Repeater {
                        model: configDialogFilterModel
                        delegate: ConfigCategoryDelegate {}
                    }
                    Repeater {
                        model: !root.isContainment ? globalConfigModel : undefined
                        delegate: ConfigCategoryDelegate {}
                    }
                }
            }

            Rectangle {
                id: separator
                color: Kirigami.Theme.highlightColor
                visible: categoriesScroll.visible
                opacity: categoriesScroll.activeFocus && Window.active ? 1 : 0.3
                Behavior on color {
                    ColorAnimation {
                        duration: units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            QtControls.ScrollView {
                id: scroll

                activeFocusOnTab: false

                implicitWidth: pageColumn.implicitWidth
                implicitHeight: pageColumn.implicitHeight

                property Item flickableItem: pageFlickable
                // this horrible code below ensures the control with active focus stays visible in the window
                // by scrolling the view up or down as needed when tabbing through the window
                Window.onActiveFocusItemChanged: {
                    var flickable = scroll.flickableItem;

                    var item = Window.activeFocusItem;
                    if (!item) {
                        return;
                    }

                    // when an item within ScrollView has active focus the ScrollView,
                    // as FocusScope, also has it, so we only scroll in this case
                    if (!scroll.activeFocus) {
                        return;
                    }

                    var padding = units.gridUnit * 2 // some padding to the top/bottom when we scroll

                    var yPos = item.mapToItem(scroll.contentItem, 0, 0).y;
                    if (yPos < flickable.contentY) {
                        flickable.contentY = Math.max(0, yPos - padding);

                    // The "Math.min(padding, item.height)" ensures that we only scroll the item into view
                    // when it's barely visible. The logic was mostly meant for keyboard navigating through
                    // a list of CheckBoxes, so this check keeps us from trying to scroll an inner ScrollView
                    // into view when it implicitly gains focus (like plasma-pa config dialog has).
                    } else if (yPos + Math.min(padding, item.height) > flickable.contentY + flickable.height) {
                        flickable.contentY = Math.min(flickable.contentHeight - flickable.height,
                                                    yPos - flickable.height + item.height + padding);
                    }
                }
                Flickable {
                    id: pageFlickable
                    anchors.fill: parent
                    contentHeight: pageColumn.height
                    contentWidth: width
                    ColumnLayout {
                        id: pageColumn
                        spacing: units.largeSpacing / 2

                        Kirigami.Heading {
                            id: pageTitle
                            Layout.fillWidth: true
                            level: 1
                            text: pageStack.title + pageStack.currentItem.implicitHeight
                        }

                        QtControls.StackView {
                            id: pageStack
                            property string title: ""
                            property bool invertAnimations: false

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            implicitWidth: Math.max(currentItem ? currentItem.implicitWidth : 0, units.gridUnit * 15)
                            implicitHeight: Math.max(currentItem ? currentItem.implicitHeight : 0, units.gridUnit * 15)

                            property string sourceFile

                            onSourceFileChanged: {
                                if (!sourceFile) {
                                    return;
                                }

                                //in a StackView pages need to be initialized with stackviews size, or have none
                                var props = {"width": width, "height": height}

                                var plasmoidConfig = plasmoid.configuration
                                for (var key in plasmoidConfig) {
                                    props["cfg_" + key] = plasmoid.configuration[key]
                                }

                                var newItem = replace(Qt.resolvedUrl(sourceFile), props)

                                for (var key in plasmoidConfig) {
                                    var changedSignal = newItem["cfg_" + key + "Changed"]
                                    if (changedSignal) {
                                        changedSignal.connect(root.settingValueChanged)
                                    }
                                }

                                var configurationChangedSignal = newItem.configurationChanged
                                if (configurationChangedSignal) {
                                    configurationChangedSignal.connect(root.settingValueChanged)
                                }

                                scroll.flickableItem.contentY = 0

                                /*
                                for (var prop in currentItem) {
                                    if (prop.indexOf("cfg_") === 0) {
                                        currentItem[prop+"Changed"].connect(root.pageChanged)
                                    }
                                }*/
                            }

                            replaceEnter: Transition {
                                ParallelAnimation {
                                    //OpacityAnimator when starting from 0 is buggy (it shows one frame with opacity 1)
                                    NumberAnimation {
                                        property: "opacity"
                                        from: 0
                                        to: 1
                                        duration: units.longDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                    XAnimator {
                                        from: pageStack.invertAnimations ? -scroll.width/3: scroll.width/3
                                        to: 0
                                        duration: units.longDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                            replaceExit: Transition {
                                ParallelAnimation {
                                    OpacityAnimator {
                                        from: 1
                                        to: 0
                                        duration: units.longDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                    XAnimator {
                                        from: 0
                                        to: pageStack.invertAnimations ? scroll.width/3 : -scroll.width/3
                                        duration: units.longDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }
//END UI components
}
