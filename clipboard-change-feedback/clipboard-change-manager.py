#!/usr/bin/env python
"""
Show a popup when clipboard contents change
"""

import time
import dbus
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib
# from PyQt5 import QtWidgets, QtCore
# import sys



DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()


class SignalHandler:
    def __init__(self, threshold):
        self.last_signal_time = 0
        self.threshold = threshold

    def on_clipboard_history_updated(self):
        current_time = time.time()
        # Ignorine signal if is too close to the last one
        if current_time - self.last_signal_time > self.threshold:
            # print("Clipboard history updated!")
            # show_popup("Clipboard contents changed")
            self.show_osd()
            self.last_signal_time = current_time

    def show_osd(self):
        osd_proxy = bus.get_object("org.kde.plasmashell", "/org/kde/osdService")
        osd_service = dbus.Interface(osd_proxy, "org.kde.osdService")
        osd_service.showText("edit-paste", "Clipboard contents changed")



# def show_popup(message, x=100, y=100):
#     app = QtWidgets.QApplication(sys.argv)
#     w = QtWidgets.QLabel(message)
#     w.setWindowFlags(QtCore.Qt.Tool | QtCore.Qt.FramelessWindowHint)
#     w.setStyleSheet("background-color: black; color: white; padding: 10px; border-radius: 5px;")
#     w.move(x, y)
#     w.show()
#     QtCore.QTimer.singleShot(2000, app.quit)  # auto-close after 2 seconds
#     app.exec_()




if __name__ == "__main__":
    handler = SignalHandler(threshold=0.1)
    bus.add_signal_receiver(
        handler.on_clipboard_history_updated,
        dbus_interface="org.kde.klipper.klipper",
        signal_name="clipboardHistoryUpdated",
    )

    GLib.MainLoop().run()