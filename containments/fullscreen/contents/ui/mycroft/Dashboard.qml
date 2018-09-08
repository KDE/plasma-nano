/*
 *  Copyright 2018 Marco Martin <mart@kde.org>
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

import org.kde.kirigami 2.5 as Kirigami

Item {
    anchors.fill: parent
    MouseArea {
        id: dashbardView
        anchors.fill: parent
        property real currentIndex: 0
        property int startX
        property int count: children.length
        onPressed: {
           switchTimer.running = false;
           startX = mouse.x;
        }
        onReleased: {
            if (mouse.x - startX < width/4) {
                dashbardView.currentIndex = (Math.round(dashbardView.currentIndex) + 1) % dashbardView.count
            } else if (mouse.x - startX > width/4) {
                if (currentIndex == 0) {
                    currentIndex = dashbardView.count-1;
                } else {
                    currentIndex--;
                }
            }
            switchTimer.restart();
        }
        ItemBase {
            index: 0
            Kirigami.Heading {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                text: "News item from a newspaper"
            }
        }
        ItemBase {
            index: 1
            RowLayout {
                Kirigami.Icon {
                    source: "weather-few-clouds"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.enormous
                    Layout.preferredHeight: Layout.preferredWidth
                }
                Kirigami.Heading {
                    //anchors.centerIn: parent
                //   horizontalAlignment: Text.AlignHCenter
                    text: "Overcast, 26 ºC"
                }
            }
        }
        ItemBase {
            index: 2
            Kirigami.Heading {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                text: "You have an appointment today at 15:30"
            }
        }

    }
    Timer {
        id: switchTimer
        interval: 10000
        running: true
        repeat: true
        onTriggered: dashbardView.currentIndex = (Math.round(dashbardView.currentIndex) + 1) % dashbardView.count
    }
    Controls.PageIndicator {
        visible: dashbardView.visible
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Kirigami.Units.largeSpacing * 3
        }
        count: dashbardView.count
        currentIndex: dashbardView.currentIndex
    }
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 0
        verticalOffset: 2
    }
}

