project(nanoshellprivate)

set(nanoshellprivate_SRCS
    nanoshellprivateplugin.cpp
    fullscreenoverlay.cpp
    )

add_library(plasmananoshellprivateplugin SHARED ${nanoshellprivate_SRCS})
target_link_libraries(plasmananoshellprivateplugin Qt5::Core Qt5::Qml Qt5::Quick  KF5::WindowSystem KF5::WaylandClient)

install(TARGETS plasmananoshellprivateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/nanoshell)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/nanoshell)


