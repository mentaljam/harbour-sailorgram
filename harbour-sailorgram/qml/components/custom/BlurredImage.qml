import QtQuick 2.1
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

Item
{
    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property alias cache: image.cache

    Image
    {
        id: image
        anchors.fill: parent
        asynchronous: true
        fillMode: Image.PreserveAspectFit
    }

    FastBlur
    {
        anchors.fill: image
        source: image
        radius: !mediamessageitem.downloaded ? 32.0 : 0.0
        visible: !mediamessageitem.downloaded
    }

    Image
    {
        z: 2
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        width: parent.width * 0.2
        height: parent.height * 0.2

        visible: {
            if(mediamessageitem.downloading)
                return false;

            return !mediamessageitem.downloaded || mediamessageitem.isVideo;
        }

        source: {
            if(mediamessageitem.isVideo && mediamessageitem.downloaded)
                return "image://theme/icon-m-play";

            return "image://theme/icon-m-cloud-download";
        }
    }

    BusyIndicator { z: 2; size: BusyIndicatorSize.Small; anchors.centerIn: parent; running: mediamessageitem.downloading }

    MouseArea
    {
        anchors.fill: parent
        enabled: !mediamessageitem.isSticker && !messageslist.selectionMode

        onClicked: {
            if(mediamessageitem.downloaded) {
                if(mediamessageitem.isVideo)
                    pageStack.push(Qt.resolvedUrl("../../pages/media/MediaPlayerPage.qml"), { source: mediamessageitem.source, thumbnail: mediamessageitem.videoThumbnail });
                else
                {
                    var imgviewerpage = pageStack.push(Qt.resolvedUrl("../../pages/media/ImageViewerPage.qml"), { source: imagemessage.source });
                    imgviewerpage.saveToDownloadsRequested.connect(function() { mediamessageitem.saveToDownloads(); });
                }

                return;
            }

            mediamessageitem.download();
        }
    }
}
