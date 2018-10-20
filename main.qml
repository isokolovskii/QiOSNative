import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QiOSNative 1.0

ApplicationWindow {
    visible: true
    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint

    NativeTextField {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 20
        }
        onFocusChanged: console.debug(focus + " " + activeFocus)

        backgroundColor: "#DDDDDD"
        color: "#222222"
        borderStyle: NativeTextField.BorderStyleRoundedRect
        horizontalAlignment: NativeTextField.AlignHCenter
        enableReturnKeyAutomatically: true
        borderColor: "#FF0000"
        borderWidth: 5
        radius: 10

        font {
            family: "Helvetica Neue"
            pointSize: 30
        }

        height: 60
        placeholder: "Test placeholder"
        keyboardType: NativeTextField.KeyboardTypeDefault
        keyboardAppearance: NativeTextField.KeyboardAppearanceDark
        autocorretionType: NativeTextField.AutocorrectionTypeNo
        returnKeyType: NativeTextField.ReturnKeyDone
        enabled: true
    }
}
