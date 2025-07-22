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
echo "开始 DIY2 配置……"
echo "========================="
#
git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git  package/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-app-advancedplus.git  package/luci-app-advancedplus

# 修改主机名字，把Unicorn修改成你喜欢的（不能纯数字或者使用中文）
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"
# Update feeds
./scripts/feeds update -a
# 调整upnp到网络菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/controller/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/model/cbi/upnp/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/view/*.htm
#
./scripts/feeds install -a
﻿#
echo "========================="
echo " DIY2 配置完成……"
