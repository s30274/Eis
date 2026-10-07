pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import "." as Screenshot

Singleton {
    id: root
    property bool isOpen: false

    IpcHandler {
        target: "screenshot"

        function open() {
            root.isOpen = true;
        }

        function close() {
            root.isOpen = false;
        }

        function toggle() {
            root.isOpen = !root.isOpen;
        }
    }

    LazyLoader {
        active: root.isOpen
        Screenshot.Overlay {
            controller: root
        }
    }
}

