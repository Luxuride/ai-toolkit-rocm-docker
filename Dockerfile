# ============================================================
# ai-toolkit-ROCm-Docker
# Based on: https://github.com/ostris/ai-toolkit/tree/main/docker
# Adapted for AMD ROCm GPU acceleration
# ============================================================

FROM rocm/pytorch:rocm7.2.4_ubuntu24.04_py3.12_pytorch_release_2.10.0

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONPATH=/opt/ai-toolkit
ENV PYTHONUNBUFFERED=1

ARG GIT_COMMIT=main

# Install system dependencies (not already in base rocm/pytorch image)
RUN apt-get update && apt-get install --no-install-recommends -y \
    cmake \
    ffmpeg \
    tmux \
    htop \
    python3-opencv \
    openssh-server \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 23.x
WORKDIR /tmp
RUN curl -sL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# ----- Clone source -----
RUN git clone https://github.com/ChuloAI/ai-toolkit.git /opt/ai-toolkit-src && \
    cd /opt/ai-toolkit-src && \
    git checkout ${GIT_COMMIT}

# ----- Install Python dependencies -----
RUN pip3 install --no-cache-dir -r /opt/ai-toolkit-src/requirements.txt

# ----- Install Node dependencies -----
RUN cd /opt/ai-toolkit-src/ui && npm ci

# ----- Copy source into place (preserving installed node_modules) -----
RUN rsync -a --delete \
        --exclude '.git' \
        --exclude 'ui/node_modules' \
        /opt/ai-toolkit-src/ /opt/ai-toolkit/ && \
    rm -rf /opt/ai-toolkit-src

# ----- Build UI (prisma generate + TypeScript build) -----
RUN cd /opt/ai-toolkit/ui && \
    npm run update_db && \
    npm run build

# ----- Copy repo defaults for init script -----
RUN mkdir -p /opt/ai-toolkit_defaults && \
    cp -r /opt/ai-toolkit/datasets /opt/ai-toolkit_defaults/datasets 2>/dev/null || true && \
    cp -r /opt/ai-toolkit/output /opt/ai-toolkit_defaults/output 2>/dev/null || true && \
    cp -r /opt/ai-toolkit/config /opt/ai-toolkit_defaults/config 2>/dev/null || true

# ----- Copy HF cache defaults for init script -----
RUN mkdir -p /root/.cache_defaults && \
    cp -r /root/.cache/huggingface /root/.cache_defaults/ 2>/dev/null || true

# ----- Init and entrypoint scripts -----
COPY init_defaults.sh /opt/init_defaults.sh
RUN chmod +x /opt/init_defaults.sh

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Expose UI port
EXPOSE 8675

# Declare mountable volumes
VOLUME ["/opt/ai-toolkit/models", "/opt/ai-toolkit/datasets", "/opt/ai-toolkit/output", "/opt/ai-toolkit/checkpoints", "/opt/ai-toolkit/config", "/opt/ai-toolkit/db", "/root/.cache"]

WORKDIR /opt/ai-toolkit

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD []