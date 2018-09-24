
install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/plasma-minishell.desktop
        DESTINATION ${KDE_INSTALL_DATADIR}/xsessions
)

install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/plasma-minishell-wayland.desktop
        DESTINATION ${KDE_INSTALL_DATADIR}/wayland-sessions
        RENAME plasma-minishell.desktop
)

