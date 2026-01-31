FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV USER=dev
ENV UID=1000
ENV GID=1000


# ---- base packages + SSH server ----
RUN apt update && apt install -y curl git sudo openssh-server

#  build-essential

# ---- create dev user ----
RUN groupadd -g ${GID} ${USER} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && echo "${USER}:devpass" | chpasswd \
 && usermod -aG sudo ${USER} \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---- setup SSH ----
RUN mkdir -p /var/run/sshd \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

USER ${USER}
WORKDIR /home/${USER}

ENV NVM_DIR=/home/${USER}/.nvm
# ---- install NVM and Node.js ----
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
 && bash -c "source $NVM_DIR/nvm.sh && nvm install 24 && nvm alias default 24" \
 && bash -c "source $NVM_DIR/nvm.sh && node -v && npm -v"


ENV GO_VERSION=1.25.6
# ---- install Go ----
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /home/${USER} -xz \
 && mv /home/${USER}/go /home/${USER}/.go

ENV PATH="${NVM_DIR}/versions/node/v24.13.0/bin:/home/${USER}/.go/bin:${PATH}"


# ---- expose SSH port ----
EXPOSE 22

# ---- generate SSH host keys ----
# RUN ssh-keygen -A

# ---- start SSH + bash ----
# ---- start SSH in foreground ----
# ---- start SSH in background, then bash ----
CMD ["bash", "-c", "sudo ssh-keygen -A && sudo /usr/sbin/sshd & exec bash"]
