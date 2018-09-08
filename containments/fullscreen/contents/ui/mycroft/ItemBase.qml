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
    id: root

    property int index

    x: Math.min(width/2, Math.max(-width/2, (width * (index - parent.currentIndex))))
    width: parent.width
    height: parent.height
    opacity: index == parent.currentIndex

    Behavior on x {
        XAnimator {
            duration: Kirigami.Units.longDuration*3
            easing.type: Easing.InOutCubic
        }
    }
    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration*2
            easing.type: Easing.InOutCubic
        }
    }
}

