dev:
	mkdir -p $(HOME)/devcontainer-workspace
	podman build -t devcontainer .
	podman run --replace -it \
		--name devcontainer \
		-p 2222:22 \
		-v $(HOME)/devcontainer-workspace:/home/dev/workspace \
		devcontainer

# dev2:
# 	podman build -t devcontainer .
# 	podman run --replace -it --name devcontainer devcontainer

dangerous-delete-all: 
	podman system prune -a