import QtQuick 2.1
import Sailfish.Silica 1.0
import "../models"

Item
{
    property Context context

    visible: !context.sailorgram.connected
    width: busyindicator.width + lblconnecting.contentWidth + Theme.paddingMedium

    BusyIndicator
    {
        id: busyindicator
        size: BusyIndicatorSize.Small
        anchors { left: parent.left; verticalCenter: lblconnecting.verticalCenter }
        running: !context.sailorgram.connected
    }

    Label
    {
        id: lblconnecting
        text: qsTr("Not connected")
        anchors { left: busyindicator.right; top: parent.top; bottom: parent.bottom; leftMargin: Theme.paddingMedium }
        color: Theme.secondaryHighlightColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }
}
