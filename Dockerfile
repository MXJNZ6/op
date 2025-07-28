FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    flex \
    bison \
    gdb \
    gawk \
    ncurses-dev \
    libncurses5-dev \
    python3 \
    python3-distutils \
    python3-setuptools \
    git \
    gettext \
    libssl-dev \
    xsltproc \
    rsync \
    unzip \
    file \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 执行初始化脚本
RUN bash <(curl -s https://build-scripts.immortalwrt.org/init_build_environment.sh) || true

# 设置工作目录
WORKDIR /workspace
