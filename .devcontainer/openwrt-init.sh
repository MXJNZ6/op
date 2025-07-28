#!/bin/bash
set -e

# 环境变量（和 workflow 保持一致）
REPO_URL="https://github.com/immortalwrt/immortalwrt"
REPO_BRANCH="master"
CONFIG_FILE="X86_imm.config"
DIY_SH="diy-imm.sh"
WORKDIR="/workspaces/$(basename $(pwd))"

# 1. 安装依赖
sudo apt-get update
sudo apt-get install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache clang cmake cpio curl device-tree-compiler flex gawk gcc-multilib g++-multilib gettext genisoimage git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool llvm lrzsz msmtp ninja-build p7zip p7zip-full patch pkgconf python3 python3-pyelftools python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev

# 2. 拉取 OpenWrt 源码
if [ ! -d "$WORKDIR/openwrt" ]; then
  git clone "$REPO_URL" -b "$REPO_BRANCH" "$WORKDIR/openwrt"
fi

# 3. 软链接源码目录
ln -sf "$WORKDIR/openwrt" "$WORKDIR/openwrt"

# 4. 执行 diy 脚本
if [ -f "$WORKDIR/$DIY_SH" ]; then
  chmod +x "$WORKDIR/$DIY_SH"
  cd "$WORKDIR/openwrt"
  "$WORKDIR/$DIY_SH"
  cd "$WORKDIR"
fi

# 5. 放置 config 文件（如存在）
if [ -f "$WORKDIR/$CONFIG_FILE" ]; then
  cp "$WORKDIR/$CONFIG_FILE" "$WORKDIR/openwrt/.config"
fi

echo "✅ OpenWrt 代码和依赖已准备好。"
echo "👉 进入 openwrt 目录后，可直接 make menuconfig 交互配置。"
