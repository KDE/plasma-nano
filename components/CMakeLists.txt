project(nanoshellprivate)

set(nanoshellprivate_SRCS
    fullscreenoverlay.cpp
    fullscreenoverlay.h
    nanoshellprivateplugin.cpp
    nanoshellprivateplugin.h
    startupnotifier.cpp
    startupnotifier.h
    )

add_library(plasmananoshellprivateplugin SHARED ${nanoshellprivate_SRCS})
target_link_libraries(plasmananoshellprivateplugin Qt5::Core Qt5::Qml Qt5::Quick  KF5::WindowSystem KF5::WaylandClient KF5::Service)

install(TARGETS plasmananoshellprivateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/nanoshell)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/nanoshell)

install(DIRECTORY qml DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/nanoshell/)


