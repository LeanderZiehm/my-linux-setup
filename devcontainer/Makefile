dev:
	podman build -t devcontainer .
	podman run --replace -it --name devcontainer devcontainer

dangerous-delete-all: 
	podman system prune -a