#FROM wlsaidhi/msamp-te:te-1.3-pytorch-23.09-0.8
FROM msamp-dev-cuda121

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV SHELL=/bin/bash
ENV PYTHONUNBUFFERED=True
ENV DEBIAN_FRONTEND=noninteractive

# Override the default huggingface cache directory.
ENV HF_HOME="/runpod-volume/.cache/huggingface/"
ENV HF_DATASETS_CACHE="/runpod-volume/.cache/huggingface/datasets/"
ENV DEFAULT_HF_METRICS_CACHE="/runpod-volume/.cache/huggingface/metrics/"
ENV DEFAULT_HF_MODULES_CACHE="/runpod-volume/.cache/huggingface/modules/"
ENV HUGGINGFACE_HUB_CACHE="/runpod-volume/.cache/huggingface/hub/"
ENV HUGGINGFACE_ASSETS_CACHE="/runpod-volume/.cache/huggingface/assets/"

# Faster transfer of models from the hub to the container
ENV HF_HUB_ENABLE_HF_TRANSFER="1"

# Shared python package cache
ENV VIRTUALENV_OVERRIDE_APP_DATA="/runpod-volume/.cache/virtualenv/"
ENV PIP_CACHE_DIR="/runpod-volume/.cache/pip/"

# Set Default Python Version
ENV PYTHON_VERSION="3.10"

WORKDIR /

# Update, upgrade, install packages and clean up
RUN apt-get update --yes && \
    apt-get upgrade --yes && \

    # Basic Utilities
    apt install --yes --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    file \
    git \
    inotify-tools \
    libgl1 \
    lsof \
    vim \
    nano \
    tmux \
    nginx \

    # Required for SSH access
    openssh-server \

    procps \
    rsync \
    sudo \
    software-properties-common \
    unzip \
    wget \
    zip && \

    # Build Tools and Development
    apt install --yes --no-install-recommends \
    build-essential \
    make \
    cmake \
    gfortran \
    libblas-dev \
    liblapack-dev && \


    # Deep Learning Dependencies and Miscellaneous
    apt install --yes --no-install-recommends \
    libatlas-base-dev \
    libffi-dev \
    libhdf5-serial-dev \
    libsm6 \
    libssl-dev && \

    # File Systems and Storage
    apt install --yes --no-install-recommends \
    cifs-utils \
    nfs-common \
    zstd &&\

    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \

    # Set locale
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen



#### DO NOT REMOVE
COPY env.sh /workspace/env.sh
#RUN source /workspace/env.sh
WORKDIR /root
### DO NOT REMOVE


RUN pip3 install transformers
RUN pip3 install timm
RUN pip3 install protobuf==3.20.*
RUN pip3 install datasets

# change/remote as needed
RUN git clone https://github.com/SolitaryThinker/dotfiles.git
WORKDIR /root/dotfiles/
RUN chmod +x setup.sh
RUN ./setup.sh -cf vim
RUN ./setup.sh -cf bash
RUN rm /root/.gitconfig
RUN stow git
#RUN cp ~/dotfiles/git/.gitconfig ~/

WORKDIR /workspace/
RUN wget -P /workspace/ \
    https://github.com/git-lfs/git-lfs/releases/download/v3.4.1/git-lfs-linux-amd64-v3.4.1.tar.gz \
    && \
    tar -xvf git-lfs-linux-amd64-v3.4.1.tar.gz && \
    sudo /workspace/git-lfs-3.4.1/install.sh

RUN ldconfig





# NGINX Proxy
COPY nginx.conf /etc/nginx/nginx.conf
#COPY --from=proxy readme.html /usr/share/nginx/html/readme.html

# Copy the README.md
#COPY README.md /usr/share/nginx/html/README.md

# Start Scripts
COPY start.sh /
#COPY post_start.sh /
RUN chmod +x /start.sh
    #chmod +x /post_start.sh

# Welcome Message
#COPY --from=logo runpod.txt /etc/runpod.txt
#RUN echo 'cat /etc/runpod.txt' >> /root/.bashrc
#RUN echo 'echo -e "\nFor detailed documentation and guides, please visit:\n\033[1;34mhttps://docs.runpod.io/\033[0m and \033[1;34mhttps://blog.runpod.io/\033[0m\n\n"' >> /root/.bashrc

CMD ["/start.sh"]
