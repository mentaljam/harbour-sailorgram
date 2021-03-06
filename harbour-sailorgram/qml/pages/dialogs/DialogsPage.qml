import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.sailorgram.TelegramQml 2.0
import "./../../components/telegram"
import "../../components"
import "../../models"
import "../../menus"
import "../../components/search"
import "../../items/dialog"
import "../../js/TelegramHelper.js" as TelegramHelper

Page
{
    property Context context

    id: dialogspage
    allowedOrientations: defaultAllowedOrientations

    Component.onCompleted: {
        context.mainPage = dialogspage;
    }

    onStatusChanged: {
        if(dialogspage.status !== PageStatus.Active)
            return;

        if(!canNavigateForward)
            pageStack.pushAttached(Qt.resolvedUrl("../contacts/ContactsPage.qml"), { "context": dialogspage.context });

        context.notifications.resetCurrentDialog();
    }

    Connections
    {
        target: context.sailorgram

        onOpenDialogRequested: {
            if(pageStack.depth > 1)
                pageStack.pop(dialogspage, PageStackAction.Immediate);

            var sgdialogitem  = context.dialogs.dialog(peerkey);

            if(!sgdialogitem) {
                console.warn("Invalid DialogItem");
                return;
            }

            pageStack.push(Qt.resolvedUrl("DialogPage.qml"), { "context": dialogspage.context, "sgDialogItem": sgdialogitem });

            if(Qt.application.state !== Qt.ApplicationActive)
                mainwindow.activate();
        }
    }

    SilicaFlickable
    {
        anchors.fill: parent

        PullDownMenu
        {
            id: dialogsmenu

            MenuItem
            {
                text: qsTr("Exit")
                visible: context.sailorgram.keepRunning
                onClicked: Qt.quit()
            }

            TelegramMenuItem
            {
                text: qsTr("New Secret Chat")
                context: dialogspage.context
                onClicked: pageStack.push(Qt.resolvedUrl("../../pages/secretdialogs/CreateSecretDialogPage.qml"), { "context": dialogspage.context })
            }

            TelegramMenuItem
            {
                text: qsTr("New Group")
                context: dialogspage.context
                onClicked: pageStack.push(Qt.resolvedUrl("../../pages/chat/CreateChatPage.qml"), { "context": dialogspage.context })
            }

            MenuItem
            {
                id: searchfield
                text: context.showsearchfield ? qsTr("Hide Search Field") : qsTr("Show Search Field")

                onClicked: {
                    context.showsearchfield = context.showsearchfield ? false : true;

                    if(context.showsearchfield)
                        lvdialogs.positionViewAtBeginning();
                    else
                        lvdialogs.headerItem.resetSearchBox();
                }
            }
        }

        PageHeader
        {
            id: pageheader
            title: context.sailorgram.connected ? qsTr("Chats") : qsTr("Connecting...")

            ConnectionStatus {
                context: dialogspage.context
                anchors { verticalCenter: pageheader.extraContent.verticalCenter; left: pageheader.extraContent.left; leftMargin: -Theme.horizontalPageMargin }
            }
        }

        SilicaListView
        {
            ViewPlaceholder { enabled: lvdialogs.count <= 0 /*(lvdialogs.count <= 0 && (lvdialogs.headerItem.count <= 0)) */; text: qsTr("No Chats\n\nDo a swype to the right to select a contact") }

            id: lvdialogs
            anchors { left: parent.left; top: pageheader.bottom; right: parent.right; bottom: parent.bottom }
            model: context.dialogs //FIXME: (lvdialogs.headerItem.count > 0) ? null : context.dialogs
            spacing: Theme.paddingMedium
            clip: true

            /* FIXME:
            header: MessageSearchList {
                id: messagesearchlist
                width: parent.width
                context: dialogspage.context

                onMessageClicked: {
                    var dialog = context.telegram.messageDialog(message.id);
                    pageStack.push(Qt.resolvedUrl("DialogPage.qml"), { "context": dialogspage.context, "dialog": dialog })
                }
            }
            */

            delegate: DialogItem {
                id: dialogitem
                contentWidth: parent.width
                contentHeight: Theme.itemSizeSmall
                context: dialogspage.context
                sgDialogItem: model.item
                onClicked: pageStack.push(Qt.resolvedUrl("DialogPage.qml"), { "context": dialogspage.context, "sgDialogItem": model.item })

                menu: DialogItemMenu {
                    sgDialogItem: model.item

                    onDeleteRequested: {
                        dialogitem.remorseAction(remorsemsg, function() {
                            context.dialogs.deleteDialog(model.item);
                        });
                    }
                }
            }
        }
    }
}
