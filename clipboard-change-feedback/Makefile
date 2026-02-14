run:
	python clipboard-changed-manager.py

install:
	bash install.sh

service-start:
	systemctl --user start clipboard-feedback.service

service-stop:
	systemctl --user stop clipboard-feedback.service

service-restart:
	systemctl --user restart clipboard-feedback.service


# run:
# 	QT_QPA_PLATFORM=xcb python clipboard-changed-manager.py