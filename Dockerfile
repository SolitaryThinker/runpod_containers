#FROM tensorrt_llm/release:latest
#FROM wlsaidhi/te-nsys:latest
FROM wlsaidhi/msamp-te:te-1.2-pytorch-23.09
#FROM wlsaidhi/trt-llm-devel
#FROM nvcr.io/nvidia/pytorch:23.10-py3

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

    apt install --yes --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    file \
    git \
    inotify-tools \
    libgl1 \
    vim \
    nano \
    tmux \
    nginx \
    stow \

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
    #apt install --yes --no-install-recommends \
    #libatlas-base-dev \
    #libffi-dev \
    #libhdf5-serial-dev \
    #libsm6 \
    #libssl-dev && \

    # File Systems and Storage
    apt install --yes --no-install-recommends \
    cifs-utils \
    nfs-common \
    zstd &&\

    # Add the Python PPA and install Python versions
    #add-apt-repository ppa:deadsnakes/ppa && \
    #apt install --yes --no-install-recommends \
    #python3.7-dev \
    #python3.7-venv \
    #python3.7-distutils \
    #python3.8-dev \
    #python3.8-venv \
    #python3.8-distutils \
    #python3.9-dev \
    #python3.9-venv \
    #python3.9-distutils \
    #python3.10-dev \
    #python3.10-venv \
    #python3.10-distutils \
    #python3.11-dev \
    #python3.11-venv \
    #python3.11-distutils && \

    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \

    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

#### DO NOT REMOVE
COPY env.sh /workspace/env.sh
RUN source /workspace/env.sh
WORKDIR /root
### DO NOT REMOVE


# change/remote as needed
RUN git clone https://github.com/SolitaryThinker/dotfiles.git
WORKDIR /root/dotfiles/
RUN chmod +x setup.sh
#RUN ./setup.sh -cf vim
#RUN ./setup.sh -cf bash
#RUN rm /root/.gitconfig
#RUN stow git

WORKDIR /workspace/
#RUN git clone https://github.com/NVIDIA/TensorRT-LLM.git

#RUN mkdir will && \
    #cd will/ && \
    #git clone https://github.com/SolitaryThinker/TensorRT-LLM.git



WORKDIR /workspace/

# change as needed
#RUN wget \
#https://huggingface.co/datasets/anon8231489123/ShareGPT_Vicuna_unfiltered/resolve/main/ShareGPT_V3_unfiltered_cleaned_split.json
#RUN mv ShareGPT_V3_unfiltered_cleaned_split.json share_gpt.json


WORKDIR /

# NGINX Proxy
COPY nginx.conf /etc/nginx/nginx.conf
#COPY readme.html /usr/share/nginx/html/readme.html

# Copy the README.md
#COPY README.md /usr/share/nginx/html/README.md


# Start Scripts
COPY start.sh /
RUN chmod +x /start.sh

# Welcome Message
#COPY --from=logo runpod.txt /etc/runpod.txt
#RUN echo 'cat /etc/runpod.txt' >> /root/.bashrc
#RUN echo 'echo -e "\nWelcome to RunPod!\nFor detailed documentation and guides, please visit:\n\033[1;34mhttps://docs.runpod.io/docs\033[0m\n\n"' >> /root/.bashrc

CMD ["/start.sh"]
