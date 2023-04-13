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


# 修改主机名字，把Unicorn修改你喜欢的就行（不能纯数字或者使用中文）
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g" ./package/base-files/files/bin/config_generate

git clone https://github.com/thinktip/luci-theme-neobird.git package/luci-theme-neobird

# Update feeds
./scripts/feeds update -a


# Install feeds
./scripts/feeds install -a
