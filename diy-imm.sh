#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
echo "开始 DIY 配置……"
echo "========================="


git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git  package/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-app-advancedplus.git  package/luci-app-advancedplus
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"
# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a
﻿#
echo "========================="
echo " DIY 配置完成……"
