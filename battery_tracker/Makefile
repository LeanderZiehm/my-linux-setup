test:
	bash ./battery_tracker.sh

install:
	bash ./install.sh

uninstall:
	systemctl --user disable --now battery-tracker.service || true
	rm -f ~/.config/systemd/user/battery-tracker.service
	rm -f ~/.local/bin/battery-tracker.sh
	systemctl --user daemon-reexec
	@echo "Battery reporter removed"

status:
	systemctl --user status battery-tracker.service

logs:
	journalctl --user -u battery-tracker.service -f
