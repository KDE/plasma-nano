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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.2 as Controls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    id: root

    function toggleAirplane() {
        print("toggle airplane mode")
    }

    spacing: units.largeSpacing
    property Controls.Drawer drawer

    property int screenBrightness
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: {
            if (source === "PowerDevil") {
                disconnectSource(source);
                connectSource(source);
            }
        }

        onDataChanged: {
            root.screenBrightness = pmSource.data["PowerDevil"]["Screen Brightness"];
        }
    }


    Flow {
        id: flow
        Layout.alignment: Qt.AlignHCenter
       /* Layout.minimumHeight: implicitHeight
        Layout.preferredWidth: parent.width*/
        Layout.preferredWidth: (children.length * (delegateSize + Kirigami.Units.largeSpacing) < drawer.width)
                    ? implicitWidth : drawer.width
        Layout.minimumWidth: 0
        spacing: Kirigami.Units.largeSpacing

        property int delegateSize: Kirigami.Units.iconSizes.medium * 2 + Kirigami.Units.smallSpacing*2

        HomeDelegate {}
        DisableMycroftDelegate {}
        SystemSettingsDelegate {}
    }


    RowLayout {
        PlasmaCore.SvgItem {
            Layout.preferredWidth: units.iconSizes.medium
            Layout.preferredHeight: Layout.preferredWidth
            //TODO: put in theme
            svg: PlasmaCore.Svg {
                colorGroup: PlasmaCore.ColorScope.colorGroup
                imagePath: Qt.resolvedUrl("./brightness-decrease.svg")
            }
        }

        PlasmaComponents.Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            value: root.screenBrightness
            onMoved: {
                var service = pmSource.serviceForSource("PowerDevil");
                var operation = service.operationDescription("setBrightness");
                operation.brightness = value;
                operation.silent = true
                service.startOperationCall(operation);
            }
            from: to > 100 ? 1 : 0
            to: root.maximumScreenBrightness
            //stepSize: 1
        }

        PlasmaCore.SvgItem {
            Layout.preferredWidth: units.iconSizes.medium
            Layout.preferredHeight: Layout.preferredWidth
            //TODO: put in theme
            svg: PlasmaCore.Svg {
                colorGroup: PlasmaCore.ColorScope.colorGroup
                imagePath: Qt.resolvedUrl("./brightness-increase.svg")
            }
        }
    }
}
