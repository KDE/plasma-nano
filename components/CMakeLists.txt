project(minishellprivate)

set(minishellprivate_SRCS
    minishellprivateplugin.cpp
    fullscreenpanel.cpp
    )

add_library(plasmaminishellprivateplugin SHARED ${minishellprivate_SRCS})
target_link_libraries(plasmaminishellprivateplugin Qt5::Core Qt5::Qml Qt5::Quick  KF5::WindowSystem KF5::WaylandClient)

install(TARGETS plasmaminishellprivateplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/minishell)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/minishell)


