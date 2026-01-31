FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV USER=dev
ENV UID=1000
ENV GID=1000
ENV GO_VERSION=1.25.6
ENV NVM_DIR=/home/${USER}/.nvm

# ---- base packages ----
RUN apt update && apt install -y curl git sudo build-essential

# ---- create dev user ----
RUN groupadd -g ${GID} ${USER} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && echo "${USER}:devpass" | chpasswd \
 && usermod -aG sudo ${USER} \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER}
WORKDIR /home/${USER}

# ---- install NVM and Node.js ----
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
 && bash -c "source $NVM_DIR/nvm.sh && nvm install 24 && nvm alias default 24" \
 && bash -c "source $NVM_DIR/nvm.sh && node -v && npm -v"

# ---- install Go ----
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /home/${USER} -xz \
 && mv /home/${USER}/go /home/${USER}/.go

ENV PATH="${NVM_DIR}/versions/node/v24.13.0/bin:/home/${USER}/.go/bin:${PATH}"

CMD ["bash"]
