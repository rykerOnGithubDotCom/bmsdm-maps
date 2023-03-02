import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import CrowbarCollective 1.0

RouteView {
    property int headerHeight: Math.ceil(85 * Theme.widthScale)
    property int headerMargin: Math.ceil(35 * Theme.widthScale)
    property int headerFontSize: Math.ceil(32 * Theme.heightScale)

    property int labelWidth: Math.ceil(150 * Theme.widthScale)
    property int labelFontSize: Math.ceil(18 * Theme.heightScale)

    property int optionHeight: Math.ceil(60 * Theme.heightScale)

    function handleSettingsChange(model, value) {
        model.value = value; // lol
    }


    Item {
        width: Math.ceil(900 * Theme.widthScale)
        height: Math.ceil(700 * Theme.heightScale)

        anchors.centerIn: parent
        anchors.verticalCenterOffset: Math.ceil(20 * Theme.heightScale)

        Item { id: header
            anchors.topMargin: 1
            anchors.leftMargin: 1
            anchors.rightMargin: 1

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            width: parent.width
            height: headerHeight

            Rectangle {
                anchors.fill: parent
                color: Theme.colors.modalBackground
                opacity: Theme.opacity.modal
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.colors.highlight
                font.family: Theme.fonts.bold
                font.pixelSize: headerFontSize
                font.capitalization: Font.AllUppercase
                text: BlackMesaEngine.getLocalizedString("#BlackMesaUI_Multiplayer_HostGame")
                leftPadding: headerMargin
            }
        }

        Rectangle {
            anchors.bottomMargin: 0
            anchors.leftMargin: 1
            anchors.rightMargin: 1

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: footer.top

            color: Theme.colors.skrim
            opacity: Theme.opacity.modal
        }

        Item { id: contents
            anchors.top: header.bottom
            anchors.bottom: footer.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20

            Component.onCompleted: {
                [
                    fragLimit,
                    serverName,
                    map,
                    timeLimit,
                    teams,
                    respawn
                ].forEach(function (row) {
                    row.requestSettingsChange.connect(handleSettingsChange);
                });
            }

            Item { id: serverNameContainer
                width: parent.width
                height: optionHeight

                OptionsListRow { id: serverName
                    anchors.top: parent.top
                    model: ListElement { id: serverNameModel
                        property string label: BlackMesaEngine.getLocalizedString("#BlackMesaUI_Multiplayer_ServerName")
                        property string type: "text"
                        property string value: "Black Mesa: Deathmatch Server"
                    }
                    onRequestSettingsChange: handleSettingsChange
                }
            }

            Item { id: mapContainer
                anchors.top: serverNameContainer.bottom
                width: parent.width
                height: 169

                OptionsListRow { id: map
                    anchors.top: parent.top
                    model: ListElement { id: mapModel
                        property string label: BlackMesaEngine.getLocalizedString("#BlackMesaUI_Multiplayer_Map")
                        property string type: "map"
                        property string value: "q3dm17"
                        property variant options: [
                            'dm_bounce',
                            'q3dm17',
                            'dm_chopper',
                            'dm_crossfire',
                            'dm_gasworks',
                            'dm_lambdabunker',
                            'dm_power',
                            'dm_rail',
                            'dm_stack',
                            'dm_stalkyard',
                            'dm_subtransit',
                            'dm_undertow'
                        ];
                    }
                    onRequestSettingsChange: handleSettingsChange
                }
            }

            Item { id: fragLimitContainer
                anchors.top: mapContainer.bottom
                width: parent.width
                height: optionHeight

                OptionsListRow { id: fragLimit
                    anchors.top: parent.top
                    model: ListElement { id: fragLimitModel
                        property string label: BlackMesaEngine.getLocalizedString("#BlackMesaUI_Multiplayer_FragLimit")
                        property string type: "text"
                        property real value: 15
                    }
                    onRequestSettingsChange: handleSettingsChange
                }
            }

            Item { id: timeLimitContainer
                anchors.top: fragLimitContainer.bottom
                width: parent.width
                height: optionHeight

                OptionsListRow { id: timeLimit
                    anchors.top: parent.top
                    model: ListElement { id: timeLimitModel
                        property string label: BlackMesaEngine.getLocalizedString("#BlackMesaUI_Multiplayer_TimeLimit")
                        property string type: "text"
                        property real value: 10
                    }
                    onRequestSettingsChange: handleSettingsChange
                }
            }

            Item { id: teamPlayContainer
                anchors.top: timeLimitContainer.bottom
                width: parent.width
                height: optionHeight

                OptionsListRow { id: teams
                    anchors.top: parent.top
                    model: ListElement { id: teamsModel
                        property string label: BlackMesaEngine.getLocalizedString("#BlackMesaUI_Multiplayer_TeamPlay")
                        property string type: "checkbox"
                        property string value: "true" // bools confuse the bindings
                    }
                    onRequestSettingsChange: handleSettingsChange
                }
            }

            Item { id: respawnContainer
                anchors.top: teamPlayContainer.bottom
                width: parent.width
                height: optionHeight

                OptionsListRow { id: respawn
                    anchors.top: parent.top
                    model: ListElement { id: respawnModel
                        property string label: BlackMesaEngine.getLocalizedString("#BlackMesaUI_Multiplayer_ForceRespawn")
                        property string type: "checkbox"
                        property string value: "false"
                    }
                    onRequestSettingsChange: handleSettingsChange
                }
            }
        }

        Item { id: footer
            anchors.bottomMargin: 1
            anchors.leftMargin: 1
            anchors.rightMargin: 1

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            width: parent.width
            height: headerHeight

            Rectangle {
                anchors.fill: parent
                color: Theme.colors.modalBackground
                opacity: Theme.opacity.modal
            }
            
            Timer {
                id: launchGameTimer
                interval: 125
                running: false
                repeat: true
                onTriggered: {
                    if (!BlackMesaEngine.isInGame()) {
                        BlackMesaEngine.setConsoleVariableAsString("hostname", serverNameModel.value)

                        BlackMesaEngine.setConsoleVariableAsInt("mp_timelimit", timeLimitModel.value)
                        BlackMesaEngine.setConsoleVariableAsInt("mp_fraglimit", fragLimitModel.value)

                        BlackMesaEngine.setConsoleVariableAsBoolean("mp_teamplay", JSON.parse(teamsModel.value))
                        BlackMesaEngine.setConsoleVariableAsBoolean("mp_forcerespawn", JSON.parse(respawnModel.value))

                        BlackMesaEngine.setConsoleVariableAsBoolean("mp_friendlyfire", false)
                        BlackMesaEngine.setConsoleVariableAsBoolean("mp_flashlight", false)

                        BlackMesaEngine.setConsoleVariableAsInt("mp_timelimit", 900)
                        BlackMesaEngine.setConsoleVariableAsInt("mp_warmup_time", 15)

                        BlackMesaEngine.setConsoleVariableAsBoolean("sv_lan", false)
                    
                        BlackMesaEngine.executeClientCommandUnrestricted("sv_cheats 0; maxplayers %1; map %2".arg(12).arg(mapModel.value))
                        
                        launchGameTimer.stop()
                        launchButton.enabled = true
                    }
                }
            }

            CTAButton { id: launchButton
                anchors.centerIn: parent
                text: BlackMesaEngine.getLocalizedString("#BlackMesaUI_Multiplayer_LaunchGame")
                onClicked: {
                    BlackMesaEngine.executeClientCommandUnrestricted("disconnect")

                    launchGameTimer.start()
                    launchButton.enabled = false
                }
            }
        }
    }
}
