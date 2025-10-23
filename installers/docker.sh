#!/bin/bash
# Source: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
export PS4='\033[0;33m$0:$LINENO [$?]+ \033[0m '
set -x

ununstall_docker() {
	# 1. Uninstall the Docker Engine, CLI, containerd, and Docker Compose packages:
	sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
	# 2. Images, containers, volumes, or custom configuration files on your host aren't automatically removed. To delete all images, containers, and volumes:
	sudo rm -rf /var/lib/docker
	sudo rm -rf /var/lib/containerd
	# 3. Remove source list and keyrings
	sudo rm /etc/apt/sources.list.d/docker.list
	sudo rm /etc/apt/keyrings/docker.asc
	# 4. 
	echo "You have to delete any edited configuration files manually."
}

install_docker() {
	# Install Docker
	if which docker &>/dev/null
	then
		echo [COMPLETE] docker already installed!
	else
		#1. Set up Docker's apt repository.
		# Add Docker's official GPG key:
		sudo apt-get update
		sudo apt-get install ca-certificates curl
		sudo install -m 0755 -d /etc/apt/keyrings
		sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
		sudo chmod a+r /etc/apt/keyrings/docker.asc
		# Add the repository to Apt sources:
		echo \
		  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
		  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
		  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt-get update

		# 2. Install the Docker packages.
		sudo apt-get install --yes \
			docker-ce \
			docker-ce-cli \
			containerd.io \
			docker-buildx-plugin \
			docker-compose-plugin

		#3. Verify that the installation is successful
		sudo systemctl status docker || return 1
	fi
}

postinstall_docker() {
	# linux-postinstall: https://docs.docker.com/engine/install/linux-postinstall/
	# Manage Docker as a non-root user
	sudo groupadd docker
	sudo usermod -aG docker $USER
	newgrp docker
	docker run hello-world

	# Configure Docker to start on boot with systemd
	sudo systemctl enable docker.service; sleep 2
	sudo systemctl enable containerd.service; sleep 2
	sudo systemctl disable docker.service; sleep 2
	sudo systemctl disable containerd.service

	echo [COMPLETE] docker installed!
	popd

	# Docker images
	# DOCKER_IMAGES=()
	# DOCKER_IMAGES+=("pihole/pihole")
	# DOCKER_IMAGES+=("bettercap/bettercap")
	# DOCKER_IMAGES+=("frolvlad/alpine-python2")
	# DOCKER_IMAGES+=("frolvlad/alpine-python3")
	# for dimage in ${DOCKER_IMAGES[$@]}
	# do
	# 	[[ "$(docker images -q ${dimage} 2> /dev/null)" == "" ]] && docker pull "${diamge}" || echo "[COMPLETE] ${dimage}"
	# done
}

case "$#" in
	"0" | "1")
		install_docker
		;;
	*)
		postinstall_docker 
		;;
esac
