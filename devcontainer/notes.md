
#  apt update && 
# ---- base packages ----
# ca-certificates \
# curl \
# git
# build-essential \
# pkg-config \
# openssh-client \
# && rm -rf /var/lib/apt/lists/*



# ---- create a non-root user ----
# # ---- Go ----
# ENV GO_VERSION=1.22.1
# RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
#  | tar -xz -C /home/${USER}

# ENV PATH="/home/${USER}/go/bin:${PATH}"

# # ---- Rust ----
# RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
# 