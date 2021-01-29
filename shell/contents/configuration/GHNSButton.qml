
import QtQuick 2.14
import org.kde.newstuff 1.62 as NewStuff

NewStuff.Button {
    configFile: "wallpaper.knsrc"
    text: i18nd("plasma_wallpaper_org.kde.image", "Download...")
    viewMode: NewStuff.Page.ViewMode.Preview
    onChangedEntriesChanged: imageWallpaper.newStuffFinished();
}
