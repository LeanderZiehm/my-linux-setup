run:
	python clipboard-change-manager.py

install install.sh:
	bash install.sh

service-start start:
	systemctl --user start clipboard-feedback.service

service-stop stop:
	systemctl --user stop clipboard-feedback.service

service-restart restart:
	systemctl --user restart clipboard-feedback.service

service-logs logs:
	journalctl --user -u clipboard-feedback.service


# run:
# 	QT_QPA_PLATFORM=xcb python clipboard-changed-manager.py
