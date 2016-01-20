import QtQuick 2.1
import Sailfish.Silica 1.0

MessageMediaItem
{
    id: messagesticker
    contentWidth: maxWidth
    contentHeight: maxWidth
    fileHandler.onTargetTypeChanged: fileHandler.download(); // Autodownload stickers

    MessageThumbnail
    {
        id: thumb
        anchors.fill: parent
        cache: !messagesticker.fileHandler.downloaded
        source: messagesticker.mediaThumbnail
        transferProgress: progressPercent
    }
}