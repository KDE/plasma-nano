
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    var desk = desktopsArray[j];
    desk.wallpaperPlugin = "org.kde.slideshow";
    desk.addWidget("org.kde.plasma.digitalclock");
    var quicklaunch = desk.addWidget("org.kde.plasma.quicklaunch");
    quicklaunch.writeConfig("launcherUrls", ["file:///usr/share/applications/net.bs.mycroft.gui.desktop", "file:///usr/share/applications/net.bs.mycroft.gui.device3.desktop", "file:///usr/share/applications/net.bs.mycroft.gui.device.desktop", "file:///usr/share/applications/net.bs.mycroft.gui.device2.desktop", "file:///usr/share/applications/net.bs.mycroft.installer.desktop", "file:///usr/share/applications/org.kde.konsole.desktop"]);
    quicklaunch.writeConfig("maxSectionCount", "2");
    quicklaunch.writeConfig("showLauncherNames", "true");
//    desk.addWidget("org.kde.plasma.mycroftplasmoid");

    desk.currentConfigGroup = new Array("Wallpaper","org.kde.slideshow","General");
    desk.writeConfig("SlideInterval", 480);
    desk.writeConfig("SlidePaths", "/usr/share/wallpapers/");
}

var panel = new Panel("org.kde.mycroft.panel")
panel.location = "top";
panel.height = 2 * gridUnit;
panel.addWidget("org.kde.plasma.battery");
panel.addWidget("org.kde.plasma.networkmanagement");
//panel.hiding = "windowsbelow";
