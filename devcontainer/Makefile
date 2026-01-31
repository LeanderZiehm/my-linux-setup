dev:
	podman build -t devcontainer . && podman start -ai devcontainer 2>/dev/null || podman run -it --name devcontainer devcontainer

dangerous-delete-all: 
	podman system prune -a