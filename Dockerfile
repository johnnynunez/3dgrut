FROM ubuntu:24.04

ARG CUDA_VERSION=12.8
ENV CUDA_VERSION=${CUDA_VERSION}
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated ca-certificates \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    wget git \
    curl \
    build-essential \
    gcc-11 g++-11 \
    libgl1-mesa-dev \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda install -y python=${PYTHON_VERSION} && \
    /opt/conda/bin/conda clean -ya
ENV PATH=/opt/conda/bin:$PATH
RUN conda init

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics
ENV FORCE_CUDA=1
RUN if [ "$CUDA_VERSION" = "12.6" ]; then \
      echo 'export TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.7;8.9"' >> /etc/profile.d/cuda_arch.sh; \
    else \
      echo 'export TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.7;8.9;9.0;10.0;10.1;12.0"' >> /etc/profile.d/cuda_arch.sh; \
    fi


WORKDIR /workspace
COPY . .

RUN ./install_env.sh 3dgrut WITH_GCC11 $CUDA_VERSION
RUN echo "conda activate 3dgrut" >> ~/.bashrc
