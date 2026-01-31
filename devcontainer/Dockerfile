FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# ---- base packages ----
RUN apt update && apt install -y curl git sudo

# ---- create a dev user with password ----
ARG USER=dev
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && echo "${USER}:devpass" | chpasswd \
 && usermod -aG sudo ${USER}

# ---- allow passwordless sudo (optional but handy in playgrounds) ----
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---- switch to dev user ----
USER ${USER}
WORKDIR /home/${USER}

CMD ["bash"]
