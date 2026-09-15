#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

echo "开始 DIY 配置……"
echo "========================="

echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"
echo "src-git momo https://github.com/nikkinikki-org/OpenWrt-momo.git;main" >> "feeds.conf.default"

# Update feeds
./scripts/feeds update -a

# 修改openwrt登陆地址,把下面的10.10.10.254修改成你需要的
sed -i 's/192.168.1.1/10.10.10.254/g' package/base-files/files/bin/config_generate

# 修改主机名字，把Unicorn修改成你喜欢的（不能纯数字或者使用中文）
sed -i "s/hostname='ImmortalWrt'/hostname='Unicorn'/g" ./package/base-files/files/bin/config_generate

rm -rf package/luci-app-amlogic
git clone -b main https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
git clone https://github.com/sirpdboy/luci-theme-kucat.git
git clone https://github.com/sirpdboy/luci-app-kucat-config.git package/luci-app-kucat-config
git clone https://github.com/eamonxg/luci-theme-aurora.git package/luci-theme-aurora
git clone https://github.com/Tokisaki-Galaxy/luci-app-tailscale-community.git package/tailscale

./scripts/feeds install -a
./scripts/feeds install -f luci-app-amlogic

echo "========================="
echo " DIY 配置完成……"
