/***************************************************************************
 *   Copyright 2015 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "fullscreenoverlay.h"

#include <QStandardPaths>

#include <QDebug>
#include <QGuiApplication>
#include <QScreen>
#include <kwindowsystem.h>

#include <KWayland/Client/connection_thread.h>
#include <KWayland/Client/plasmashell.h>
#include <KWayland/Client/registry.h>
#include <KWayland/Client/surface.h>

FullScreenOverlay::FullScreenOverlay(QQuickWindow *parent)
    : QQuickWindow(parent)
{
    setFlags(Qt::FramelessWindowHint);
    setWindowState(Qt::WindowFullScreen);
   // connect(this, &FullScreenOverlay::activeFocusItemChanged, this, [this]() {qWarning()<<"hide()";});
    initWayland();
    setWindowStates(Qt::WindowFullScreen);
}

FullScreenOverlay::~FullScreenOverlay()
{
}

void FullScreenOverlay::initWayland()
{
    if (!QGuiApplication::platformName().startsWith(QLatin1String("wayland"), Qt::CaseInsensitive)) {
        return;
    }
    using namespace KWayland::Client;
    ConnectionThread *connection = ConnectionThread::fromApplication(this);
    if (!connection) {
        return;
    }
    Registry *registry = new Registry(this);
    registry->create(connection);

    m_surface = Surface::fromWindow(this);
    if (!m_surface) {
        return;
    }
    connect(registry, &Registry::plasmaShellAnnounced, this,
        [this, registry] (quint32 name, quint32 version) {

            m_plasmaShellInterface = registry->createPlasmaShell(name, version, this);

            m_plasmaShellSurface = m_plasmaShellInterface->createSurface(m_surface, this);
            m_plasmaShellSurface->setSkipTaskbar(true);
        }
    );

    registry->setup();
    connection->roundtrip();
    //HACK: why the first time is shown fullscreen won't work?
    showFullScreen();
    hide();
}

bool FullScreenOverlay::event(QEvent *e)
{
    if (e->type() == QEvent::FocusIn || e->type() == QEvent::FocusOut) {
        emit activeChanged();
    } else if (e->type() == QEvent::PlatformSurface) {
        QPlatformSurfaceEvent *pe = static_cast<QPlatformSurfaceEvent*>(e);

        if (pe->surfaceEventType() == QPlatformSurfaceEvent::SurfaceCreated) {
            //KWindowSystem::setState(winId(), NET::SkipTaskbar | NET::SkipPager | NET::FullScreen);
           // setWindowStates(Qt::WindowFullScreen);
            if (m_plasmaShellSurface) {
                m_plasmaShellSurface->setSkipTaskbar(true);
            }

            if (!m_acceptsFocus) {
                setFlags(flags() | Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus);
                //KWindowSystem::setType(winId(), NET::Dock);
            } else {
                setFlags(flags() | Qt::FramelessWindowHint);
            }
        }
    } else if (e->type() == QEvent::Show) {
        if (m_plasmaShellSurface) {
            m_plasmaShellSurface->setSkipTaskbar(true);
        }
    }

    return QQuickWindow::event(e);
}

#include "fullscreenoverlay.moc"

