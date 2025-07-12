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
function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}
function drop_package(){
    find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}
function merge_feed(){
    if [ ! -d "feed/$1" ]; then
        echo >> feeds.conf.default
        echo "src-git $1 $2" >> feeds.conf.default
    fi
    ./scripts/feeds update $1
    ./scripts/feeds install -a -p $1
}
rm -rf package/custom; mkdir package/custom
#
merge_package https://github.com/vernesong/OpenClash OpenClash/luci-app-openclash
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/custom/luci-app-openclash/tools/po2lmo
make && sudo make install
popd
#
git clone https://github.com/fw876/helloworld.git package/ssr
git clone https://github.com/jerrykuku/luci-theme-argon.git  package/luci-theme-argon
git clone -b js https://github.com/sirpdboy/luci-theme-kucat.git  package/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-app-advancedplus.git  package/luci-app-advancedplus
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/luci-app-unblockneteasemusic
# 修改openwrt登陆地址,把下面的10.10.10.254修改成你需要的
sed -i 's/192.168.1.1/10.10.10.254/g' package/base-files/files/bin/config_generate
# 修改主机名字，把Unicorn修改成你喜欢的（不能纯数字或者使用中文）
sed -i "/uci commit system/i\uci set system.@system[0].hostname='Unicorn'" package/lean/default-settings/files/zzz-default-settings
sed -i "s/hostname='OpenWrt'/hostname='Unicorn'/g" ./package/base-files/files/bin/config_generate
# Update feeds
./scripts/feeds update -a
#mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
# 删除包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-unblockmusic
rm -rf feeds/packages/multimedia/UnblockNeteaseMusic-Go
# 调整upnp到网络菜单
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/controller/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/model/cbi/upnp/*.lua
sed -i 's/services/network/g' feeds/luci/applications/luci-app-upnp/luasrc/view/*.htm
#
./scripts/feeds install -a -f
﻿#
echo "========================="
echo " DIY2 配置完成……"
