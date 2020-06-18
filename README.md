Plasma Nano
=======================

A minimal plasma shell package intended for embedded devices

Plasma Nano Build Instructions
==============================

```bash
git clone https://invent.kde.org/plasma/plasma-nano
cd plasma-nano
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
sudo make install
```

Test on a development machine
=======================

```bash
plasmashell -p org.kde.plasma.nano
```

List of Dependencies
====================

- KDE KF5 Dependencies:
  - Plasma
  - WindowSystem
  - KWayland
  
- Qt Dependencies:
  - Core
  - Gui
  - Qml
  - Quick
