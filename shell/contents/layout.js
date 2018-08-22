
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
    desktopsArray[j].addWidget("org.kde.plasma.analogclock");
    desktopsArray[j].addWidget("org.kde.plasma.mycroftplasmoid");
}
